# frozen_string_literal: true

FactoryGirl.define do
  factory :settings, class: OpenStruct do
    skip_create
    initialize_with { OpenStruct.new }
    after(:create) do |settings|
      settings.server_url = 'http://example.com'

      settings.jwt = OpenStruct.new
      settings.jwt.expiration_hours = 24

      settings.data_directory = 'tmp/data'

      worker_group = OpenStruct.new(workers: 2, classes: 'ApplicationWorker')
      settings.sneakers = [worker_group]
    end
  end
end
