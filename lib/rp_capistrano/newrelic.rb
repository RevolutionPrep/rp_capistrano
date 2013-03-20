require 'new_relic/recipes'

module RPCapistrano
  module NewRelic
    def self.load_into(configuration)
      configuration.load do
        after 'deploy:update', 'rp:newrelic:enable_monitoring'
        after 'rp:newrelic:enable_monitoring', 'rp:newrelic:deploy'
        after 'rp:newrelic:deploy', 'newrelic:notice_deployment'

        namespace :rp do
          namespace :newrelic do
            task :enable_monitoring, :roles => :web do
              run "cp #{release_path}/config/newrelic.enable.yml #{release_path}/config/newrelic.yml"
            end

            desc "Sets newrelic deployment parameters"
            task :deploy, :except => { :no_release => true } do

              set :fresh_revision, fetch(:previous_revision, 'HEAD^3')
              set :newrelic_revision, fetch(:note, fetch(:fresh_revision, 'HEAD'))
              set :newrelic_appname, fetch(:app_name)
              set :newrelic_desc, `uname -a`

              run "cd #{fetch(:release_path)} && git log --no-color --pretty=format:'  * %an: %s' --abbrev-commit --no-merges #{fetch(:fresh_revision, 'HEAD^3')}..HEAD", :roles => :app, :only => { :primary => true }  do |ch, stream, data|
                set :newrelic_changelog, data
              end

              puts " ** CHANGES ======================================================"
              puts fetch(:newrelic_changelog, "  ! Unable to get changes")
              puts " ** =============================================================="
              puts "\n"
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
