module RPCapistrano
  module Foreman
    def self.load_into(configuration)
      configuration.load do
        namespace :foreman do
          after  'deploy:update', 'foreman:export'
          after  'deploy:migrations', 'foreman:export'
          before 'foreman:export', 'foreman:copy_env'
          after  'foreman:export', 'foreman:stop'
          after  'foreman:stop', 'foreman:kill_resque_processes'
          after  'foreman:kill_resque_processes', 'foreman:start'

          # Adapted from https://raw.github.com/ddollar/foreman/master/lib/foreman/capistrano.rb
          # for use with rvm
          desc <<-DESC
            Export the Procfile to upstart.  Will use sudo if available.

            You can override any of these defaults by setting the variables shown below.

            set :foreman_format,      "upstart"
            set :foreman_location,    "/etc/init"
            set :foreman_procfile,    "Procfile"
            set :foreman_app,         application
            set :foreman_user,        user
            set :foreman_log,         "#{shared_path}/log"
            set :foreman_concurrency, false
          DESC
          task :export, roles: :app do
            bundle_cmd          = fetch(:bundle_cmd, "bundle")
            foreman_format      = fetch(:foreman_format, "upstart")
            foreman_location    = fetch(:foreman_location, "/etc/init")
            foreman_procfile    = fetch(:foreman_procfile, "Procfile")
            foreman_app         = fetch(:foreman_app, application)
            foreman_user        = fetch(:foreman_user, user)
            foreman_log         = fetch(:foreman_log, "#{shared_path}/log")
            foreman_concurrency = fetch(:foreman_concurrency, false)

            args = ["#{foreman_format} #{foreman_location}"]
            args << "-f #{foreman_procfile}"
            args << "-a #{foreman_app}"
            args << "-u #{foreman_user}"
            args << "-l #{foreman_log}"
            args << "-c #{foreman_concurrency}" if foreman_concurrency
            run "cd #{latest_release} && rvmsudo #{bundle_cmd} exec foreman export #{args.join(' ')}"
          end

          desc "Start the application services"
          task :start, roles: :app do
            run "#{sudo} start #{application} ;true"
          end

          desc "Stop the application services"
          task :stop, roles: :app do
            run "#{sudo} stop #{application} ;true"
          end

          desc "Restart the application services"
          task :restart, roles: :app do
            run "#{sudo} start #{application} || #{sudo} restart #{application}"
          end

          desc "Display logs for a certain process - arg example: PROCESS=web-1"
          task :logs, roles: :app do
            run "cd #{current_path}/log && cat #{ENV["PROCESS"]}.log"
          end

          desc "Copy env file to root path"
          task :copy_env, roles: :app do
            put File.read("config/deploy/#{rails_env}/env.txt"), "#{latest_release}/.env"
          end

          desc "kill resque processes"
          task :kill_resque_processes, :roles => :app do 
            run "pkill -3 -f resque- ; true"
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  RPCapistrano::Foreman.load_into(Capistrano::Configuration.instance)
end
