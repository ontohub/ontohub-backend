# frozen_string_literal: true

FactoryBot.define do
  factory :settings, class: Hash do
    skip_create
    initialize_with { attributes }

    server_url 'http://example.com'

    jwt expiration_hours: 24

    data_directory 'tmp/data'

    git_shell do
      {copy_authorized_keys_executable: 'tmp/copy_authorized_keys',
       path: 'tmp/git-shell'}
    end

    elasticsearch do
      {
        host: 'localhost',
        port: 9200,
        prefix: nil,
      }
    end

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
