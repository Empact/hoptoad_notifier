require File.expand_path(File.dirname(__FILE__) + "/lib/insert_commands.rb")
require File.expand_path(File.dirname(__FILE__) + "/lib/rake_commands.rb")

class HoptoadGenerator < Rails::Generator::Base
  include HoptoadNotifier::Generator

  def add_options!(opt)
    opt.on('-k', '--api-key=key', String, "Your Hoptoad API key")                                               { |v| options[:api_key] = v}
    opt.on('-h', '--heroku',              "Use the Heroku addon to provide your Hoptoad API key")               { |v| options[:heroku]  = v}
    opt.on('-a', '--app=myapp', String,   "Your Heroku app name (only required if deploying to >1 Heroku app)") { |v| options[:app]     = v}
  end

  def manifest
    require_api_key!
    if plugin_is_present?
      puts "You must first remove the hoptoad_notifier plugin. Please run: script/plugin remove hoptoad_notifier"
      exit
    end
    record do |m|
      m.directory 'lib/tasks'
      m.file 'hoptoad_notifier_tasks.rake', 'lib/tasks/hoptoad_notifier_tasks.rake'
      if ['config/deploy.rb', 'Capfile'].all? { |file| File.exists?(file) }
        m.append_to 'config/deploy.rb', capistrano_hook
      end
      if api_key_expression
        if use_initializer?
          m.template 'initializer.rb', 'config/initializers/hoptoad.rb',
            :assigns => {:api_key => api_key_expression}
        else
          m.template 'initializer.rb', 'config/hoptoad.rb',
            :assigns => {:api_key => api_key_expression}
          m.append_to 'config/environment.rb', "require 'config/hoptoad'"
        end
      end
      if heroku?
        ENV['HOPTOAD_API_KEY'] ||= options[:api_key] || determine_api_key
      end
      m.rake "hoptoad:test --trace", :generate_only => true
    end
  end

  def use_initializer?
    Rails::VERSION::MAJOR > 1
  end

  def api_key_configured?
    File.exists?('config/initializers/hoptoad.rb') ||
      system("grep HoptoadNotifier config/environment.rb")
  end

  def capistrano_hook
    IO.read(source_path('capistrano_hook.rb'))
  end
end
