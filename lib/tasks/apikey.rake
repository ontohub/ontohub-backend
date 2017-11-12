# frozen_string_literal: true

namespace :apikey do
  desc "Create a new API key - set the comment with ENV['COMMENT']"
  task create: :environment do
    comment = ENV['COMMENT']
    key = ApiKey.generate(Rails.application.secrets.api_key_base, 80)
    ApiKey.create(key: key[:encoded], comment: comment)

    comment_out = comment.present? ? " (#{comment})" : ''
    $stdout.puts "Created API key#{comment_out}:"
    $stdout.puts "Raw Key:\n#{key[:raw]}"
  end
end
