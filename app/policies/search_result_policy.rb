# frozen_string_literal: true

# Policies for SearchController
class SearchResultPolicy < ApplicationPolicy
  def search?
    true
  end
end
