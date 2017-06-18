# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Types::UserType = GraphQL::ObjectType.define do
  name 'User'
  interfaces [Types::OrganizationalUnitType]

  field :id, !types.ID do
    description 'ID of the user'
    property :slug
  end

  field :displayName, types.String do
    description 'Display name of the user'
    property :display_name
  end

  field :email, types.String, 'Email address of the user'

  field :emailHash, !types.String do
    description 'MD5 hash of the user\'s email address'
    property :email_hash
  end

  field :organizations, !types[Types::OrganizationType] do
    argument :limit,
             types.Int,
             'Maximum number of organizations',
             default_value: 20
    argument :skip,
             types.Int,
             'Skip the first n organizations',
             default_value: 0
    resolve(lambda do |user, args, _ctx|
      user.organizations_dataset.limit(args[:limit], args[:skip])
    end)
  end
end
# rubocop:enable Metrics/BlockLength
