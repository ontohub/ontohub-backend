Types::QueryType = GraphQL::ObjectType.define do
  name 'Query'

  field :version, Types::VersionType do
    description 'The version of the backend'
    resolve(lambda do |_obj, _args, _ctx|
      Version.new(Version::VERSION)
    end)
  end
end
