# When Hoptoad is installed as a plugin this is loaded automatically.
#
# When Hoptoad installed as a gem, you need to add 
#  require 'hoptoad_notifier/recipes/hoptoad_recipes'
# to your deploy.rb
#
# Defines deploy:notify_hoptoad which will send information about the deploy to Hoptoad.
#
after "deploy", "deploy:notify_hoptoad"

namespace :deploy do
  Capistrano::Configuration.instance(:must_exist).load do
    task :notify_hoptoad, :roles => :app do
      rake = fetch(:rake, "rake")
      rails_env = fetch(:rails_env, "production")
      run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} hoptoad:deploy TO=#{rails_env}"
    end
  end
end
