# frozen_string_literal: true

# Policies for SearchController
class SearchResultPolicy < ApplicationPolicy
  def search?
    not_an_api_key?
  end
end
