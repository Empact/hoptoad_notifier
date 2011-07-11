class HoptoadNotifier::Heroku

  def initialize(app = nil)
    @app = " --app #{app}" if app
  end

  def rails_env
    `#{cmd(:console, "'puts RAILS_ENV'")} | head -n 1`.strip
  end

  def hoptoad_api_key
    `#{cmd(:console, "'puts ENV[%{HOPTOAD_API_KEY}]'")} | head -n 1`.strip
  end

  private

  def cmd(command, input = nil, pipes = nil)
    command = 'run console' if command.to_sym == :console && cedar_stack?
    "heroku #{command} #{input} #{@app}"
  end

  def cedar_stack?
    `#{cmd(:stack)}`.split("\n").detect {|stack| stack[0] == '*' }.include?('cedar')
  end
end
