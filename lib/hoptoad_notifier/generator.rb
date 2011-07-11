module HoptoadNotifier::Generator
  def heroku
    @heroku ||= HoptoadNotifier::Heroku.new(options[:app])
  end

  def require_api_key!
    if !api_key_configured? && !options[:api_key] && !options[:heroku]
      puts "Must pass --api-key or --heroku or create config/initializers/hoptoad.rb"
      exit
    end
  end

  def api_key_expression
    if options[:api_key]
      "'#{options[:api_key]}'"
    elsif options[:heroku]
      "ENV['HOPTOAD_API_KEY']"
    end
  end

  def determine_api_key
    puts "Attempting to determine your API Key from Heroku..."
    api_key = heroku.hoptoad_api_key
    if api_key.blank?
      puts "... Failed."
      puts "WARNING: We were unable to detect the Hoptoad API Key from your Heroku environment."
      puts "Your Heroku application environment may not be configured correctly."
      exit 1
    else
      puts "... Done."
      puts "Heroku's Hoptoad API Key is '#{api_key}'"
    end
    api_key
  end

  def heroku?
    options[:heroku] ||
      system("grep HOPTOAD_API_KEY config/initializers/hoptoad.rb") ||
      system("grep HOPTOAD_API_KEY config/environment.rb")
  end

  def plugin_is_present?
    File.exists?('vendor/plugins/hoptoad_notifier')
  end
end
