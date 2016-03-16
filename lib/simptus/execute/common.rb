require 'inifile'
require 'net/ssh'

module Simptus
  module Execute
    module Common
      def self.create_connection(server)
        if server[:ip].to_s == '127.0.0.1'
          server[:connection] = 'local'
        else
          server[:connection] = Net::SSH.start(server[:ip], server[:user],
                                               keys:  [ server[:key] ],
                                               passphrase: '')
        end
        server
      end

      def self.read_server_list
        inifile = IniFile.load(File.join(ENV['HOME'], '.simptus', 'simptus.ini'))

        servers_list = {}
        inifile.each_section do |section|
          ip   = ini_config(inifile, section, 'ip')
          user = ini_config(inifile, section, 'user')
          key  = ini_config(inifile, section, 'key')
          servers_list[section] = {
            ip:   ip,
            user: user,
            key:  key
          }
        end
        servers_list
      end

      def self.pid_file
        File.join(ENV['HOME'], '.simptus', 'simptus.pid')
      end

      def self.ini_config(inifile, section, name)
        inifile[section][name]
      end
      
      # iniファイルに記述されたサーバ分のCPU使用率、空きメモリ容量を計算して返却する。
      # server_list     :  iniファイルに記述されたサーバリストを格納。Hashオブジェクト。
      # server_resources:  CPU,メモリの各ファイルからリソース計測用に該当する行のみ格納。Hashオブジェクト。
      #                     ex) MemAvailable: 80000000 KB
      # resources_final :  整形済みのリソース情報を格納。Hashオブジェクト。
      def self.get_resource(servers_list)
        server_resources = extract_resource(servers_list)
        resources_final = {}
        server_resources.each_key do |section|

          server_name = section.to_s
          idle = server_name + '_idle'
          total = server_name + '_total'
          mem = server_name + '_mem'

          # CPU使用率を計算
          # totalとidleを取得
          # [cpu user nice system idle iowait irq softirq steal guest guest_nice]
          use_cpu = server_resources[section][:cpu].chomp.split(' ')[1 .. 10].map { |n| n.to_i }
          resources_final[total] = use_cpu.reduce { |sum, m| sum += m }
          resources_final[idle] = use_cpu[3]

          # 空きメモリ容量を計算
          # [MemAvailable: nnnnnnn KB]
          free_mem = server_resources[section][:mem].chomp.split(' ')[1].to_i
          resources_final[mem] = free_mem / 1024
        end
        resources_final
      end

      def self.extract_resource(servers_list)
        resources = {}
        servers_list.each_key do |section|
          resources[section] = {}
          connection = servers_list[section][:connection]
          if connection == 'local'
            File.open('/proc/stat', 'r') do |cpu|
              cpu.each_line do |line|
                resources[section][:cpu] = line if line =~ /^cpu /
              end
            end
            File.open('/proc/meminfo', 'r') do |mem|
              mem.each_line do |line|
                resources[section][:mem] = line if line =~ /^MemAvailable/
              end
            end
          else
            resources_raw = connection.exec! 'cat /proc/stat; cat /proc/meminfo'
            resources_raw.each_line do |line|
              resources[section][:cpu] = line if line =~ /^cpu / 
              resources[section][:mem] = line if line =~ /^MemAvailable/ 
            end
          end
        end
        resources
      end

      private_class_method :extract_resource, :ini_config
    end
  end
end
