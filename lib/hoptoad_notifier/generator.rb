module HoptoadNotifier::Generator
  def require_api_key!
    if !api_key_configured? && !options[:api_key] && !options[:heroku]
      puts "Must pass --api-key or --heroku or create config/initializers/hoptoad.rb"
      exit
    end
  end
end
