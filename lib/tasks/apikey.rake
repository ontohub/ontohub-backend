# frozen_string_literal: true

namespace :apikey do
  namespace :create do
    def rake_apikey_create(klass, comment)
      key = klass.generate(Rails.application.secrets.api_key_base, 80)
      klass.create(key: key[:encoded], comment: comment)

      comment_out = comment.present? ? " (#{comment})" : ''
      $stdout.puts "Created #{klass}#{comment_out}:"
      $stdout.puts "Raw Key:\n#{key[:raw]}"
    end

    desc "Create a new GitShell API key - set a comment with ENV['COMMENT']"
    task git_shell: :environment do
      rake_apikey_create(GitShellApiKey, ENV['COMMENT'])
    end

    desc "Create a new Hets API key - set a comment with ENV['COMMENT']"
    task hets: :environment do
      rake_apikey_create(HetsApiKey, ENV['COMMENT'])
    end
  end
end
