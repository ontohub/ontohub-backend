unless defined?(Coveralls)
	require 'simplecov'
  require 'coveralls'
  simplecov_settings = 'rails' if ENV['SIMPLECOV_RAILS']
  SimpleCov.formatters = [
		SimpleCov::Formatter::HTMLFormatter,
		Coveralls::SimpleCov::Formatter,
	]
end
