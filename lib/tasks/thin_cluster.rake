namespace :thin do
  namespace :cluster do
    desc "DRY Methods for cluster tasks"
    task :setup => :environment do
      def load_config
        config = {}
        config_file = "#{RAILS_ROOT}/config/mongrel_cluster.yml"
        if File.exist?(config_file)
          config = YAML::load_file(config_file)
        else
          config[:log_file]     = "log/thin.log"
          config[:pid_file]     = "tmp/pids/thin.pid"
          config[:port]         = 3000
          config[:environment]  = RAILS_ENV
          config[:servers]      = (RAILS_ENV == "production") ? 8 : 3
        end
        
        return config
      end
      
      def thin_command(state = "start")
        config = load_config
        command = ""
        
        case state
        when "start"
          command = (%^
thin start -A rails -d
-s #{config["servers"]}
-P #{config["pid_file"]}
-p #{config["port"]}
-l #{config["log_file"]}
-e #{config["environment"]}
          ^).split("\n").join(" ").chomp
        when "stop"
          command = (%^
thin stop -A rails -d
-s #{config["servers"]}
-P #{config["pid_file"]}
          ^).split("\n").join(" ").chomp
        end
        
        return command
      end
    end
    
    desc "Start your thin cluster"
    task :start => :setup do
      system "cd #{RAILS_ROOT}"
      
      puts "Starting thin instances: #{thin_command}"
      system thin_command
    end
    
    desc 'Stop your thin cluster'
    task :stop => :setup do
      system "cd #{RAILS_ROOT}"
      
      puts "Stopping thin instances: #{thin_command('stop')}"
      system thin_command("stop")
    end
    
    desc 'Restarting your thin cluster'
    task :restart => [:stop, :start] do
    end
  end
end