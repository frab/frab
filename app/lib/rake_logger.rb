module RakeLogger
  def error(msg)
    STDERR.puts(msg)
  end

  def warning(msg)
    STDERR.puts(msg) unless Rails.env.test?
  end

  def log(msg)
    STDOUT.puts(msg) unless ENV['QUIET']
  end
end
