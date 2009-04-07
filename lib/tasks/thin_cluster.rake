namespace :thin do
  namespace :cluster do
    desc "DRY Methods for cluster tasks"
    task :setup => :environment do
      def load_config
        config = YAML::load_file("config/mongrel_cluster.yml")
        
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
        command = (%^
thin start -A rails -d
-P #{pid_file}
-p #{port}
-l #{config["log_file"]}
-e #{config["environment"]}
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
      ^).split("\n").join(" ").strip!
      
      puts    command
      system  command
    end
    
    desc 'Restart your thin cluster'
    task :restart => [:stop, :start] do
    end
  end
end