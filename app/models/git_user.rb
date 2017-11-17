# frozen_string_literal: true

# Represents an author, committer or tagger in git
class GitUser
  attr_reader :name, :email

  def initialize(name, email)
    @name = name
    @email = email
  end

  def account
    @account ||= User.first(email: email)
  end
end
