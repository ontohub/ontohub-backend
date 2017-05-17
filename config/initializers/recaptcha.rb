# frozen_string_literal: true

Recaptcha.configure do |config|
  config.site_key = Rails.application.secrets.recaptcha['site_key']
  config.secret_key = Rails.application.secrets.recaptcha['secret_key']
  # Uncomment the following line if you are using a proxy server:
  # config.proxy = 'http://myproxy.com.au:8080'
end
