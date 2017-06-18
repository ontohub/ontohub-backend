# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.1'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making
# cross-origin AJAX possible
gem 'rack-cors'

gem 'ontohub-models', github: 'ontohub/ontohub-models',
                      branch: 'add_email_hash_field'

gem 'gitlab_git', github: 'ontohub/gitlab_git',
                  branch: 'master'

gem 'active_model_serializers', '~> 0.10.4'
gem 'config', '~> 1.4.0'

# Use these gems for debugging
gem 'awesome_print', '~> 1.7.0'
gem 'pry', '~> 0.10.4'
gem 'pry-byebug', '~> 3.4.1', platform: :mri
gem 'pry-rails', '~> 0.3.4'
gem 'pry-rescue', '~> 1.4.4', platform: :mri
gem 'pry-stack_explorer', '~> 0.4.9.2', platform: :mri

gem 'jwt', '~> 1.5.6'
gem 'recaptcha', '~> 4.1.0'
gem 'graphql', '~> 1.6.3'
gem 'graphql-batch', '~> 0.3.3'

group :development, :test do
end

group :production do
end

group :development do
  gem 'listen', '~> 3.1.5'
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'sprockets-rails', require: 'sprockets/railtie'
  gem 'graphiql-rails'
end

group :test do
  gem 'codecov', '~> 0.1.10', require: false
  gem 'database_cleaner', '~> 1.6.1'
  gem 'factory_girl_rails', '~> 4.8.0'
  gem 'faker', '~> 1.7.2'
  gem 'json-schema', '~> 2.8.0'
  gem 'rspec', '~> 3.6.0'
  gem 'rspec-rails', '~> 3.6.0'
end
