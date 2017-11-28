# frozen_string_literal: true

Types::UserType = GraphQL::ObjectType.define do
  name 'User'
  description 'Data of a user'

  implements Types::OrganizationalUnitType, inherit: true

  field :email, types.String do
    description 'Email address of the user'
    authorize :access_private_data
  end

  field :unconfirmedEmail, types.String do
    description 'Email address of the user that still needs to be confirmed'
    authorize :access_private_data
    property :unconfirmed_email
  end

  field :emailHash, !types.String do
    description "MD5 hash of the user's email address"
    property :email_hash
  end

  field :publicKeys, types[!Types::PublicKeyType] do
    description "List of a user's SSH public keys"
    authorize :access_private_data
    property :public_keys
  end

  field :organizationMemberships do
    type !types[!Types::Organization::MembershipType]
    description "List of the user's organization memberships"

    argument :limit, types.Int do
      description 'Maximum number of memberships to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n memberships'
      default_value 0
    end

    argument :role, Types::Organization::RoleEnum do
      description 'Filter the organizations by the membership role'
    end

    resolve(lambda do |user, arguments, _context|
      dataset = OrganizationMembership.where(member_id: user.id)
      dataset = dataset.where(role: arguments['role']) if arguments['role']
      dataset.join(:organizational_units, id: :organization_id).
        order(Sequel[:organizational_units][:slug]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end

  field :repositoryMemberships do
    type !types[!Types::Repository::MembershipType]
    description "List of the user's repository memberships"

    argument :limit, types.Int do
      description 'Maximum number of memberships to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n memberships'
      default_value 0
    end

    argument :role, Types::Repository::RoleEnum do
      description 'Filter the repositories by the membership role'
    end

    resolve(lambda do |user, arguments, _context|
      dataset = RepositoryMembership.where(member_id: user.id)
      dataset = dataset.where(role: arguments['role']) if arguments['role']
      dataset.join(:repositories, id: :repository_id).
        order(Sequel[:repositories][:slug]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end
end
