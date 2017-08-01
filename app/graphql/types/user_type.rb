# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Types::UserType = GraphQL::ObjectType.define do
  # rubocop:enable Metrics/BlockLength
  name 'User'
  interfaces [Types::OrganizationalUnitType]
  description 'Data of a user'

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

  field :organizations, !types[!Types::OrganizationType] do
    description 'List of organizations the user is a member of'

    argument :limit, types.Int do
      description 'Maximum number of organizations to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n organizations'
      default_value 0
    end

    argument :role, Types::Organization::RoleEnum do
      description "Filter the organizations by the user's role"
    end

    resolve(lambda do |user, arguments, _context|
      dataset = if arguments['role']
                  user.organizations_by_role(arguments['role'])
                else
                  user.organizations_dataset
                end
      dataset.order(:slug).
        limit(arguments['limit'], arguments['skip'])
    end)
  end
end
