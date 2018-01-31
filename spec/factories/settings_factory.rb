# frozen_string_literal: true

FactoryBot.define do
  factory :settings, class: Hash do
    skip_create
    initialize_with { attributes }

    server_url 'http://example.com'

    jwt expiration_hours: 24

    data_directory 'tmp/data'

    sneakers [{workers: 2, classes: 'ApplicationWorker'}]
  end
end
