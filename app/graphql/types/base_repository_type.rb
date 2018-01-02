# frozen_string_literal: true

Types::BaseRepositoryType = GraphQL::InterfaceType.define do
  name 'BaseRepository'
  description 'Basic data of a repository'

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

  field :permissions, Types::Repository::PermissionsType do
    description "The current_user's permissions for this repository"

    resolve(lambda do |repository, _arguments, context|
      return unless context[:current_user]
      if RepositoryMembership.where(repository_id: repository.id,
                                    member_id: context[:current_user].id).empty?
        return nil
      end
      repository
    end)
  end

  field :memberships, !types[!Types::Repository::MembershipType] do
    description "List of the repository's memberships"

    argument :limit, types.Int do
      description 'Maximum number of memberships to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n memberships'
      default_value 0
    end

    argument :role, Types::Repository::RoleEnum do
      description 'Filter the users by the membership role'
    end

    resolve(lambda do |repository, arguments, _context|
      dataset = RepositoryMembership.where(repository_id: repository.id)
      dataset = dataset.where(role: arguments['role']) if arguments['role']
      dataset.join(:organizational_units, id: :member_id).
        order(Sequel[:organizational_units][:slug]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end

  field :urlMappings, !types[!Types::Repository::UrlMappingType] do
    description 'List of all URL Mappings of this repository'
    property :url_mappings
  end
end
