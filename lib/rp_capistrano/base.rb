require 'capistrano'
require 'capistrano_colors'
require 'airbrake/capistrano'

module RPCapistrano
  module Base
    def self.load_into(configuration)
      configuration.load do
        after 'deploy', 'deploy:cleanup'
        before 'deploy:setup', 'rvm:create_gemset'

        # User details
        set :user,          'deployer'
        #_cset(:group)         { user }

        # Application details
        _cset(:app_name)      { abort "Please specify the short name of your application, set :app_name, 'foo'" }
        set(:application)   { app_name }
        _cset :use_sudo,      false

        # SCM settings
        set :deploy_to, "/home/#{user}/apps/#{application}"
        set :scm, 'git'
        set(:repository) { "git@github.com:RevolutionPrep/#{app_name}.git" }
        _cset :branch, $1 if `git branch` =~ /\* (\S+)\s/m
        set :deploy_via, :remote_cache
        set :ssh_options, { :forward_agent => true }

        # Let rvm isolate the gems with gemsets
        set :bundle_dir, nil
        set :bundle_flags, nil
        require 'bundler/capistrano'

        # Git settings for Capistrano
        default_run_options[:pty]     = true # needed for git password prompts

        namespace :deploy do
          task :restart do
          end

          desc "Make sure local git is in sync with remote."
          task :check_revision, :roles => :web do
            unless `git rev-parse HEAD` == `git rev-parse origin/#{branch}`
              puts "WARNING: HEAD is not the same as origin/#{branch}"
              puts "Run `git push` to sync changes."
              exit
            end
          end
          before "deploy", "deploy:check_revision"

          task :write_gitbr, :roles => :app do
            put branch, "#{release_path}/.gitbr"
          end
          after "deploy", "deploy:write_gitbr"
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  RPCapistrano::Base.load_into(Capistrano::Configuration.instance)
end
