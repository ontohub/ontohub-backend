# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.1'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making
# cross-origin AJAX possible
gem 'rack-cors'

gem 'ontohub-models', github: 'ontohub/ontohub-models',
                      branch: 'master'

gem 'gitlab_git', github: 'ontohub/gitlab_git',
                  branch: 'update_to_9.0.5'

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
gem 'orm_adapter-sequel', '~> 0.1.0'

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
end

group :test do
  gem 'coveralls', '~> 0.8.17'
  gem 'database_cleaner', '~> 1.5.3'
  gem 'factory_girl_rails', '~> 4.8.0'
  gem 'faker', '~> 1.7.2'
  gem 'json-schema', '~> 2.7.0'
  gem 'rspec', '~> 3.5.0'
  gem 'rspec-rails', '~> 3.5.2'
end
