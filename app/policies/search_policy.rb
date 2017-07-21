# frozen_string_literal: true

# Policies for SearchController
class SearchPolicy < ApplicationPolicy
  attr_reader :current_user

  def initialize(current_user, _args = nil)
    @current_user = current_user
    super
  end

  def search?
    true
  end
end
