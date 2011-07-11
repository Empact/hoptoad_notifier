namespace :hoptoad do
  desc "Notify Hoptoad of a new deploy."
  task :deploy => :environment do
    require 'hoptoad_tasks'
    HoptoadTasks.deploy(:rails_env      => ENV['TO'],
                        :scm_revision   => ENV['REVISION'],
                        :scm_repository => ENV['REPO'],
                        :local_username => ENV['USER'],
                        :api_key        => ENV['API_KEY'],
                        :dry_run        => ENV['DRY_RUN'])
  end

  task :log_stdout do
    require 'logger'
    RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)
  end

  namespace :heroku do
    desc "Install Heroku deploy notifications addon"
    task :add_deploy_notification => [:environment] do
      # `heroku console 'puts ENV[%{HOPTOAD_API_KEY}]' | head -n 1`.strip
      heroku = HoptoadNotifier::Heroku.new(ENV['APP'])
      command = %Q(heroku addons:add deployhooks:http url="http://hoptoadapp.com/deploys.txt?deploy[rails_env]=#{heroku.rails_env}&api_key=#{heroku.hoptoad_api_key}")

      puts "\nRunning:\n#{command}\n"
      puts `#{command}`
    end
  end
end
