# Simptus

Simptus is resource monitoring tool. It is agentless, manager host collct resource which execute ssh command to monitored host.

Currently, Simptus can collect resource of the cpu usage and free memory capacity.
But because it is not made firm, it can not be used as a gem. (Make quickly.)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simptus'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simptus

## Usage

Usage of simptus command:

    $ simptus help
    Commands:
    simptus command -d [INTERVAL](sec)  # Start command mode. Default interval is 600(sec).
    simptus daemon -d [INTERVAL](sec)   # Start daemon mode. Default interval is 600(sec).
    simptus help [COMMAND]              # Describe available commands or one specific command
    simptus init                        # Initialize.
    simptus kill -s [SIGNAL]            # Kill process of Simptus.
    simptus server -p [PORT]            # Start web server
    simptus status                      # Check Simptus's status

1. First, execute `simptus init`.  
   This command create `$HOME/.simptus` dir, `simptus.ini` and  `simptus_auth` file.

2. Next, edit `$HOME/.simptus/simptus.ini` file while looking at exmple.

3. If you want to check monitored host on command line mode:

        $ simptus command

   If you want to check on web interface:
   
        $ simptus daemon
        $ simptus server

   and open your web browser, access `127.0.0.1:3000`.

   If you want to end the monitoring:
   
        (Terminate server at Ctrl+c)
        $ simptus kill

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ryoana14/simptus. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

