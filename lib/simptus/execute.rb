module Simptus
  module Execute

    def self.init
      dir = "#{ENV['HOME']}/.simptus"
      unless Dir.exist?(dir)
        Dir.mkdir(dir, mode = 0700)
        puts 'Make Simptus Directory...Done'
      else
        puts 'Simptus directory is already exist. Skip.'
      end

      unless File.exist?("#{dir}/simptus.ini")
        File.open("#{dir}/simptus.ini", 'w') do |f|
          f.puts '# [<any_name>]            ;input any name. ex) hostname'
          f.puts '# ip=<ip_address>         ;input monitored host\' IP address'
          f.puts '# user=<user_name>        ;input username to be used in ssh connection'
          f.puts '# key=<rsa_key_file_path> ;input rsa key to be userd in ssh connection'
          f.puts ''
          f.puts '[localhost]'
          f.puts 'ip=127.0.0.1'
          f.puts 'user=hoge'
          f.puts 'key=/home/hoge/.ssh/fuga_rsa'
        end
        puts 'Make Simptus inifile..Done'
        puts "Please edit #{dir}/simptus.ini."
      else
        puts 'Simptus inifile already exist. Initialize is end.'
      end
    end

    def self.run_command(interval)
      command = Command.new(interval)
      command.start
    end

    def self.run_daemon(interval)
      daemon = Daemon.new(interval)
      daemon.start
    end

    def self.status
      unless File.exist?(Common.pid_file)
        status = 'stopped'
      else
        pid_file = Common.pid_file
        pid = `pgrep --pidfile #{pid_file}`
        if pid.empty?
          status = 'stopped. But pid file is exist'
        else
          status = 'runnning'
        end
      end

      puts "Simptus is #{status}."
    end

    def self.kill(signal)
      begin
        pid_file = Common.pid_file
        pid = File.open(pid_file, 'r').read.to_i

        Process.kill(signal, pid)
        File.delete(pid_file)
      rescue
        puts 'Simptus is already stopped.'
      end
    end
  end
end
