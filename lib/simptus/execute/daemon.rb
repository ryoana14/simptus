module Simptus
  module Execute
    class Daemon
      def initialize(interval)
        @interval = interval
        @pid = Common.pid_file
        @flag = false
      end

      def start
        servers_list = Common.read_server_list
        servers_list.each_key do |s|
          servers_list[s] = Common.create_connection(servers_list[s])
        end
        DB.prepare(servers_list)

        web_start
        daemonize
        set_trap
        run(servers_list)
      end

      private

      def web_start
      end

      def run(servers_list)
        loop do
          break if @flag
          res = Common.get_resource(servers_list)
          res[:time] = Time.now.strftime('%H:%M:%S')
          Resource.create!(res).reload
          sleep @interval
        end
      end

      def daemonize
        Process.daemon(true, true)
        open(@pid, 'w') { |f| f << Process.pid } if @pid
      end

      def set_trap
        Signal.trap(:INT)  { @flag = true }
        Signal.trap(:TERM) { @flag = true }
      end
    end
  end
end
