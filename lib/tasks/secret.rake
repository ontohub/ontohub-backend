# frozen_string_literal: true

require 'fileutils'

namespace :secret do
  desc 'Print out a key pair for JWT'
  task jwt: :environment do
    key_pair = JWTWrapper.generate_key_pair

    %i(public private).each do |type|
      $stdout.puts("#{type} key between the two lines:")
      $stdout.puts('#' * 80)
      $stdout.puts(key_pair[type].to_pem)
      $stdout.puts('#' * 80)
      $stdout.puts
    end
  end
end
