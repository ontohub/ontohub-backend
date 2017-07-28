# frozen_string_literal: true

# Policies for SearchController
class SearchPolicy < ApplicationPolicy
  def search?
    true
  end
end
