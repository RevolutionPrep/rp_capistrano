require 'new_relic/recipes'

module RPCapistrano
  module NewRelic
    def self.load_into(configuration)
      configuration.load do
        after 'deploy:update', 'rp:newrelic:enable_monitoring'
        after 'rp:newrelic:enable_monitoring', 'newrelic:notice_deployment'

        namespace :rp do
          namespace :newrelic do
            task :enable_monitoring, :roles => :web do
              run "cp #{release_path}/config/newrelic.enable.yml #{release_path}/config/newrelic.yml"
            end
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  RPCapistrano::NewRelic.load_into(Capistrano::Configuration.instance)
end
