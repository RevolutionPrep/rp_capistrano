module RPCapistrano
  module CopyConfig
    def self.load_into(configuration)
      configuration.load do
        before "deploy:restart", "rp:config_copy:passenger_yml"

        namespace :rp do
          namespace :config_copy do
            task :database_yml do
              run "cp #{release_path}/config/deploy/#{rails_env}/database.yml #{release_path}/config/database.yml"
            end
            task :polaris_yml do
              run "cp #{release_path}/config/deploy/#{rails_env}/polaris.yml #{release_path}/config/polaris.yml"
            end
            task :cas_yml do
              run "cp #{release_path}/config/deploy/#{rails_env}/cas_server.yml #{release_path}/config/cas_server.yml"
            end
            task :passenger_yml, :roles => :web do
              run "cp #{release_path}/config/deploy/#{rails_env}/passenger.yml /etc/passenger.d/#{app_name}.yml && sudo service passenger restart #{app_name}"
            end
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  RPCapistrano::CopyConfig.load_into(Capistrano::Configuration.instance)
end
