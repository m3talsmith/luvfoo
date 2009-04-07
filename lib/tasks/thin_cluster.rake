namespace :thin do
  namespace :cluster do
    desc "DRY Methods for cluster tasks"
    task :setup => :environment do
      def load_config
        config = {}
        config_file = "config/mongrel_cluster.yml"
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
    end
    
    desc "Start your thin cluster"
    task :start => :setup do
      system "cd #{RAILS_ROOT}"
      config  = load_config
      
      puts "Starting thin instances:"
      config["servers"].times do |i|
        port      = (config['port'] + i)
        pid_file  = config['pid_file'].split(".").join(".#{port}.")
        log_file  = config['log_file'].split(".").join(".#{port}.")
        command = (%^
thin start -A rails
-P #{pid_file}
-p #{port}
-l #{log_file}
-e #{config["environment"]}
-d
        ^).split("\n").join(" ").strip!
        
        puts command
        
        Thread.new do
          system command
        end
      end
    end
    
    desc 'Stop your thin cluster'
    task :stop => :setup do
      system "cd #{RAILS_ROOT}"
      config  = load_config
      
      puts "Stopping thin instances:"
      command = (%^
thin stop -A rails -d
-s #{config["servers"]}
-P #{config["pid_file"]}
-p #{config["port"]}
      ^).split("\n").join(" ").strip!
      
      puts    command
      system  command
    end
    
    desc 'Restart your thin cluster'
    task :restart => [:stop, :start] do
    end
  end
end