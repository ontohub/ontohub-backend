# frozen_string_literal: true

Mutations::MutationType = GraphQL::ObjectType.define do
  name 'Mutation'

  Session = Struct.new(:user)

  field :signIn, Types::Session do
    argument :username, !types.String
    argument :password, !types.String
    resolve ->(_obj, args, _ctx) do
      user = User.find(slug: args[:username])
      if user && user.valid_password?(args[:password])
        Session.new(user)
      end
    end
  end

  field :saveRepository, Types::Repository do
    argument :idOrOwner, !types.ID, 'This can be either the id of an organizational unit to create the repository, or the id of the repository to update'
    argument :repository, !Types::RepositoryInput

    resolve ->(_obj, args, _ctx) do
      if args[:idOrOwner].include?('/')
        repo = Repository.find(slug: args[:idOrOwner])
        repo.update(args[:repository].to_h.map { |k,v| { k.underscore => v} }.reduce(&:merge))
      else
        owner = OrganizationalUnit.find(slug: args[:idOrOwner])
        repo = Repository.new(owner: owner,
                              name: args[:repository][:name],
                              description: args[:repository][:description],
                              content_type: args[:repository][:contentType],
                              public_access: args[:repository][:publicAccess])
        repo.url_path_method = lambda do |r|
          "/#{r.to_param}"
        end
      end

      repo.save
    end
  end

  field :destroyRepository, !types.String do
    argument :id, !types.ID

    resolve ->(_obj, args, _ctx) do
      repo = Repository.find(slug: args[:id])
      raise 'Hello world' 
      repo.destroy
      repo.to_param
    end
  end
end
