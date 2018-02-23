# frozen_string_literal: true

# Policies for OrganizationalUnitsController
class OrganizationalUnitPolicy < ApplicationPolicy
  def show?
    not_an_api_key?
  end
end
