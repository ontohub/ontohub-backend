# frozen_string_literal: true

FactoryBot.define do
  factory :settings, class: Hash do
    skip_create
    initialize_with { attributes }

    server_url 'http://example.com'

    jwt expiration_hours: 24

    data_directory 'tmp/data'

    rabbitmq do
      {
        host: 'example.com',
        port: 1234,
        username: 'username',
        password: 'password',
        virtual_host: 'rabbitmq_test',
      }
    end

    sneakers [{workers: 2, classes: 'MailersWorker'}]
  end
end
