require 'capistrano'
require 'capistrano_colors'
require 'bundler/capistrano'
require 'airbrake/capistrano'
require 'rvm/capistrano'

module RPCapistrano
  module Base
    def self.load_into(configuration)
      configuration.load do
        after 'deploy:restart', 'deploy:cleanup'
        before 'deploy:setup', 'rvm:create_gemset'

        set :rvm_type, :system
        set :rvm_ruby_string, :local

        # User details
        _cset :user,          'capi'
        _cset(:group)         { user }
        _cset :sudo_user,     'www'

        # Application details
        _cset(:app_name)      { abort "Please specify the short name of your application, set :app_name, 'foo'" }
        set(:application)   { app_name }
        _cset :use_sudo,      false

        _cset(:passenger_user) { sudo_user }
        _cset(:passenger_group) { sudo_user }

        # SCM settings
        set :deploy_to, "/var/www/#{app_name}"
        _cset :scm, 'git'
        set(:repository) { "git@nas01:#{app_name}" }
        _cset :branch, $1 if `git branch` =~ /\* (\S+)\s/m
        _cset :deploy_via, :remote_cache

        _cset :bundle_flags, "--deployment"

        # Git settings for Capistrano
        default_run_options[:pty]     = true # needed for git password prompts
        ssh_options[:forward_agent]   = true # use the keys for the person running the cap command to check out the app

        namespace :deploy do
          task :start do ; end
          task :stop do ; end
          task :restart, :roles => :app, :except => { :no_release => true } do
            run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  RPCapistrano::Base.load_into(Capistrano::Configuration.instance)
end
