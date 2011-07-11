require 'rails/generators'
require 'hoptoad_notifier/generator'

class HoptoadGenerator < Rails::Generators::Base
  include HoptoadNotifier::Generator

  class_option :api_key, :aliases => "-k", :type => :string, :desc => "Your Hoptoad API key"
  class_option :heroku, :type => :boolean, :desc => "Use the Heroku addon to provide your Hoptoad API key"
  class_option :app, :aliases => "-a", :type => :string, :desc => "Your Heroku app name (only required if deploying to >1 Heroku app)"

  def self.source_root
    @_hoptoad_source_root ||= File.expand_path("../../../../../generators/hoptoad/templates", __FILE__)
  end

  def install
    require_api_key!
    ensure_plugin_is_not_present
    append_capistrano_hook
    generate_initializer unless api_key_configured?
    if heroku?
      ENV['HOPTOAD_API_KEY'] ||= options[:api_key] || determine_api_key
    end
    test_hoptoad
  end

  private

  def ensure_plugin_is_not_present
    if plugin_is_present?
      puts "You must first remove the hoptoad_notifier plugin. Please run: script/plugin remove hoptoad_notifier"
      exit
    end
  end

  def append_capistrano_hook
    if File.exists?('config/deploy.rb') && File.exists?('Capfile')
      append_file('config/deploy.rb', <<-HOOK)

        require './config/boot'
        require 'hoptoad_notifier/capistrano'
      HOOK
    end
  end

  def generate_initializer
    template 'initializer.rb', 'config/initializers/hoptoad.rb'
  end

  def api_key_configured?
    File.exists?('config/initializers/hoptoad.rb')
  end

  def test_hoptoad
    puts run("rake hoptoad:test --trace")
  end
end
