# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Types::RepositoryType = GraphQL::ObjectType.define do
  name 'Repository'
  description 'Data of a repository'

  field :id, !types.ID do
    description 'ID of the repository'
    property :to_param
  end

  field :name, !types.String do
    description 'Name of the repository'
  end

  field :description, types.String do
    description 'Description of the repository'
  end

  field :owner, !Types::OrganizationalUnitType do
    description 'Owner of the repository'
  end

  field :contentType, !Types::Repository::ContentTypeEnum do
    description 'Type of the repository'
    property :content_type
  end

  field :visibility, !Types::Repository::VisibilityEnum do
    description 'Visibility of the repository'
    resolve(lambda do |repository, _arguments, _context|
      repository.public_access ? 'public' : 'private'
    end)
  end

  field :defaultBranch, types.String do
    description 'Default branch of the repository'
    property :default_branch
    resolve(lambda do |repository, _arguments, _context|
      repository.git.default_branch
    end)
  end

  field :branches, !types[types.String] do
    description 'Branches of the repository'
    resolve(lambda do |repository, _arguments, _context|
      repository.git.branch_names
    end)
  end
end
