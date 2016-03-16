module Simptus
  module Execute
    class Command
      def initialize(interval)
        @interval = interval
      end

      def start
        servers_list = Common.read_server_list
        # ホスト名を抽出
        servers_name = servers_list.keys.map(&:to_s)
        # ホスト毎のリソース情報を格納するHash作成
        servers_columns = {}
        servers_name.each do |s|
          servers_columns[s] = { s + '_idle'  => 0,
                                 s + '_total' => 0,
                                 s + '_mem'   => 0 }
          servers_list[s] = Common.create_connection(servers_list[s])
        end
        
        set_trap

        loop do
          res = Common.get_resource(servers_list)
          # ホスト毎のリソース情報を格納
          servers_name.each do |s|
            si = s + '_idle'
            st = s + '_total'
            sm = s + '_mem'
            
            idle = res[si] - servers_columns[s][si]
            total = res[st] - servers_columns[s][st]
            cpu_usage = 100 - (idle.to_f / total.to_f * 100)
            printf("%10s, %3.2f %%, %4d MB\n", s, cpu_usage, res[sm])
            servers_columns[s][si] = res[si]
            servers_columns[s][st] = res[st]
          end
          sleep @interval
        end
      end

      private

      def set_trap
        Signal.trap(:INT) do
          puts 'done'
          exit 0
        end
      end
    end
  end
end
