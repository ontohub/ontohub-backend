# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

Types::UserType = GraphQL::ObjectType.define do
  name 'User'
  interfaces [Types::OrganizationalUnitType]
  description 'Data of a user'

  field :id, !types.ID do
    description 'ID of the user'
    property :slug
  end

  field :displayName, types.String do
    description 'Display name of the user'
    property :display_name
  end

  field :email, types.String do
    description 'Email address of the user'
  end

  field :unconfirmedEmail, types.String do
    description 'Email address of the user that still needs to be confirmed'
    property :unconfirmed_email
  end

  field :emailHash, !types.String do
    description "MD5 hash of the user's email address"
    property :email_hash
  end

  field :organizations, !types[Types::OrganizationType] do
    description 'List of organizations the user is a member of'

    argument :limit, types.Int do
      description 'Maximum number of organizations to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n organizations'
      default_value 0
    end

    resolve(lambda do |user, arguments, _context|
      user.organizations_dataset.limit(arguments[:limit], arguments[:skip])
    end)
  end
end
