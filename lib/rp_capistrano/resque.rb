module RPCapistrano
  module Resque
    def self.load_into(configuration)
      configuration.load do
        after 'deploy:restart', 'rp:resque:load_god_config'
        after 'rp:resque:load_god_config', 'rp:resque:restart_god_workers'

        namespace :rp do
          namespace :resque do
            desc "Load god config for resque"
            task :load_god_config, :roles => :god, :on_no_matching_servers => :continue do
              puts " ** LOADING RESQUE GOD CONFIG ====================================="
              run "sudo /usr/local/rvm/bin/boot_god load #{release_path}/config/god/resque.god"
            end

            desc "Restart god workers"
            task :restart_god_workers, :roles => :god, :on_no_matching_servers => :continue do
              puts " ** LOADING RESQUE GOD CONFIG ====================================="
              run "sudo /usr/local/rvm/bin/boot_god restart #{app_name}-resque" do |ch, stream, data|
                puts data
              end
            end

            desc "Kill resque workers and reload god config"
            task :kill_processes, :roles => :god, :on_no_matching_servers => :continue do 
              puts " ** KILLING RESQUE WORKERS ========================================"
              run "sudo ps -e -o pid,command | grep resque-1 | awk '{ if ($2!=\"grep\") system(\"echo Killing \" $2 \" \" $1 \";sudo kill -3 \" $1)}'" do |ch, stream, data|
                puts "     > #{data}"
              end
            end
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  RPCapistrano::Resque.load_into(Capistrano::Configuration.instance)
end
