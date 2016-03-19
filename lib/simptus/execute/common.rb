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
      # servers_list     :  iniファイルに記述されたサーバリストを格納。Hashオブジェクト。
      # server_resources:  CPU,メモリの各ファイルからリソース計測用に該当する行のみ格納。Hashオブジェクト。
      #                     ex) MemAvailable: 80000000 KB
      # resources_final :  整形済みのリソース情報を格納。Hashオブジェクト。
      def self.get_resource(servers_list)
        server_resources = extract_resource(servers_list)
        shape_resources = {}
        server_resources.each_key do |section|

          server_name = section.to_s
          idle = server_name + '_idle'
          total = server_name + '_total'
          mem = server_name + '_mem'

          # CPU使用率を計算
          # totalとidleを取得
          # [cpu user nice system idle iowait irq softirq steal guest guest_nice]
          use_cpu = server_resources[section][:cpu].chomp.split(' ')[1 .. 10].map { |n| n.to_i }
          shape_resources[total] = use_cpu.reduce { |sum, m| sum += m }
          shape_resources[idle] = use_cpu[3]

          # 空きメモリ容量を計算
          # [MemAvailable: nnnnnnn KB]
          if server_resources[section][:mem].is_a?(String)
            free_mem = server_resources[section][:mem].chomp.split(' ')[1].to_i
            shape_resources[mem] = free_mem / 1024
          else
            free_mem = 0
            server_resources[section][:mem].each do |m|
              free_mem += m.chomp.split(' ')[1].to_i
            end
            shape_resources[mem] = free_mem / 1024
          end
        end
        shape_resources
      end

      def self.extract_resource(servers_list)
        resources = {}
        servers_list.each_key do |section|
          resources[section] = {}
          connection = servers_list[section][:connection]
          if connection == 'local'
            cpu = ''
            File.open('/proc/stat', 'r').each_line { |l| cpu += l }
            mem = ''
            File.open('/proc/meminfo', 'r').each_line { |l| mem += l }
            raw_resources = cpu + mem
          else
            raw_resources = connection.exec! 'cat /proc/stat; cat /proc/meminfo'
          end
          resources[section][:cpu] = extract_cpu(raw_resources)
          resources[section][:mem] = extract_mem(raw_resources)
        end
        resources
      end

      def self.extract_cpu(data)
        cpu_line = ''
        data.each_line do |c|
          cpu_line = c if c =~ /^cpu /
        end
        cpu_line
      end

      def self.extract_mem(data)
        if data.include?('MemAvailable')
          mem_line = ''
          data.each_line do |m|
            if m =~ /^MemAvailable/
              mem_line = m
              break
            end
          end
        else
          mem_line = []
          data.each_line do |m|
            mem_line << m if m =~ /^MemFree|^Buffers|^Cached/
          end
        end
        mem_line
      end

      private_class_method :extract_resource, :ini_config, :extract_cpu, :extract_mem
    end
  end
end
