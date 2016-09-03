source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

gem 'ontohub-models', github: 'ontohub/ontohub-models', branch: 'create_models_as_rails_engine'

# Use these gems for debugging
gem 'pry', '~> 0.10.4'
gem 'pry-rescue', '~> 1.4.4'
gem 'pry-stack_explorer', '~> 0.4.9.2'
gem 'pry-byebug', '~> 3.4.0'
gem 'pry-coolline', '~> 0.2.5'
gem 'pry-rails', '~> 0.3.4'
gem 'awesome_print', '~> 1.7.0'

group :development, :test do
end

group :production do
end

group :development do
  # Models are in a shared gem, but we need the generators in a Rails application
  gem 'sequel-rails', '~> 0.9.14'

  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'coveralls', '~> 0.8.15'
  gem 'rspec', '~> 3.5.0'
  gem 'rspec-rails', '~> 3.5.2'
  gem 'database_cleaner', '~> 1.5.3'
  gem 'factory_girl_rails', '~> 4.7.0'
  gem 'faker', '~> 1.6.6'
end
