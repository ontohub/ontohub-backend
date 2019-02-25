# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'

# Improve boot time - This gem is not exposing a changing API, so we can leave
# out the version requirement.
gem 'bootsnap', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making
# cross-origin AJAX possible
gem 'rack-cors'

# Please check out the notes in
# * `app/graphql/mutations/confirm_email_mutation.rb`
# * `app/graphql/mutations/resend_confirmation_email_mutation.rb`
# * `app/graphql/mutations/resend_password_reset_email_mutation.rb`
# * `app/graphql/mutations/resend_unlock_account_email_mutation.rb`
# * `app/graphql/mutations/reset_password_mutation.rb`
# * `app/graphql/mutations/save_account_mutation.rb`
# * `app/graphql/mutations/sign_in_mutation.rb`
# * `app/graphql/mutations/sign_up_mutation.rb`
# * `app/graphql/mutations/unlock_account_mutation.rb`
# when the models bring in a new version of Devise
gem 'ontohub-models', github: 'ontohub/ontohub-models',
                      branch: 'master'

gem 'index', github: 'ontohub/index', branch: 'master', require: false

gem 'bringit', '~> 1.0.0'

gem 'config', '~> 1.7.0'
gem 'dry-validation'

# Use these gems for debugging
gem 'awesome_print', '~> 1.8.0'
gem 'pry', '~> 0.11.3'
gem 'pry-byebug', '~> 3.6.0', platform: :mri
gem 'pry-rails', '~> 0.3.9'
gem 'pry-rescue', '~> 1.4.4', platform: :mri
gem 'pry-stack_explorer', '~> 0.4.9.3', platform: :mri

# Sneakers depends on bunny and has the version requirement
gem 'bunny'
gem 'chewy', '~> 5.0.0'
gem 'factory_bot_rails', '~> 4.10.0' # Needed for the seeds
gem 'faker', '~> 1.9.3' # Needed for the seeds
gem 'filelock', '~> 1.1.1'
gem 'graphql', '~> 1.7.14'
gem 'graphql-batch', '~> 0.4.0'
gem 'graphql-pundit', '~> 0.7.1'
gem 'jwt', '~> 2.1.0'
gem 'pundit', '~> 1.1.0'
gem 'recaptcha', '~> 4.13.1'
gem 'sneakers', '2.7.0'

group :development, :test do
end

group :production do
end

group :development do
  gem 'fasterer', require: false
  gem 'graphiql-rails'
  # We want the process manager "invoker" to be present in the most current
  # version to be compatible with current OS versions.
  gem 'invoker'
  gem 'listen', '~> 3.1.5'
  gem 'rubocop', '~> 0.58.2', require: false
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'sprockets-rails', require: 'sprockets/railtie'
end

group :test do
  gem 'bunny-mock', '~> 1.7.0'
  gem 'codecov', '~> 0.1.14', require: false
  gem 'database_cleaner', '~> 1.7.0'
  gem 'fuubar', '~> 2.3.2'
  # As soon as a version > 2.8.0 of json-schema is released, use it instead of
  # master.
  gem 'json-schema', github: 'ruby-json-schema/json-schema', branch: 'master'
  gem 'rspec', '~> 3.8.0'
  gem 'rspec-rails', '~> 3.8.2'
end
