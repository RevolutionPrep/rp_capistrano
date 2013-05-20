module RPCapistrano
  module Rvm
    def self.load_into(configuration)
      configuration.load do
        set :rvm_type, :system
        _cset :rvm_ruby_string, :local
        require 'rvm/capistrano'

        before 'deploy:update_code', 'rp:rvm:info'
        after 'deploy:setup', 'rp:rvm:create_rake_wrapper'
        after 'deploy', 'rp:rvm:trust_rvmrc'

        namespace :rp do
          namespace :rvm do
            desc "Prints out the current rvm environment"
            task :info, :roles => :app, :only => { :primary => true } do
              puts " ** RVM INFO ======================================================"
              run "rvm info" do |ch, stream, data|
                puts data
              end
              puts " ** =============================================================="
              puts "\n"
            end

            desc "Create rake wrapper"
            task :create_rake_wrapper do
              ruby_version = /[0-9]\.[0-9]\.[0-9]/.match(rvm_ruby_string).to_s.gsub('.', '')
              run "rvm wrapper #{rvm_ruby_string} #{app_name}_#{ruby_version} rake"
            end

            desc "Trust rvmrc file"
            task :trust_rvmrc do
              run "rvm rvmrc trust #{release_path}"
            end
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  RPCapistrano::Rvm.load_into(Capistrano::Configuration.instance)
end
