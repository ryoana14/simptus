require 'thor'

module Simptus
  class CLI < Thor
    def self.define_options
      option :interval, type: :numeric, default: 600, aliases: ['-d']
    end

    desc 'init', 'Initialize.'
    def init
      Execute.init
    end

    desc 'command -d [INTERVAL](sec)', 'Start command mode. Default interval is 600(sec).'
    define_options
    def command
      puts "Start Simptus Command mode at #{options[:interval]}-second intervals"
      Execute.run_command(options[:interval])
    end

    desc 'daemon -d [INTERVAL](sec)',
         'Start daemon mode. Default interval is 600(sec).'
    define_options
    def daemon
      puts "Start Simptus Daemon mode at #{options[:interval]}-second intervals"
      Execute.run_daemon(options[:interval])
    end

    desc 'server -p [PORT]', 'Start web server'
    option :port, type: :numeric, default: 3000, aliases: ['-p']
    def server
      Execute.run_server(options[:port])
    end

    desc 'status', 'Check Simptus\'s status'
    def status
      Execute.status
    end

    desc 'kill -s [SIGNAL]', 'Kill process of Simptus.'
    option :signal, type: :string, default: 'TERM', aliases: ['-s'],
                    enum: %w(INT TERM)
    def kill
      Execute.kill(options[:signal])
    end
  end
end
