module RPCapistrano
  module Rvm
    def self.load_into(configuration)
      configuration.load do
        _cset :rvm_ruby_string, :local
        require 'rvm/capistrano'

        before 'deploy:update_code', 'rp:rvm:info'
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
