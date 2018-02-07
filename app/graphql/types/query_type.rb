# frozen_string_literal: true

Types::QueryType = GraphQL::ObjectType.define do
  name 'Query'
  description 'Base query type'

  field :me, Types::UserType do
    description 'The currently signed in user'

    resolve(lambda do |_root, _arguments, context|
      context[:current_user]
    end)
  end

  field :gitAuthorization, types.Boolean do
    description 'Tells whether or not a public key has git access'

    argument :keyId, !types.Int do
      description 'The ID of the public key for authorization'
    end

    argument :repositoryId, !types.ID do
      description 'The ID of the repository for authorization'
    end

    argument :action, !Types::GitActionEnum do
      description 'The action to authorize'
    end

    resource(lambda do |_root, arguments, _context|
      user = PublicKey.first(id: arguments[:keyId])&.user
      repository = Repository.first(slug: arguments[:repositoryId])
      {user: user, repository: repository}
    end)

    authorize(lambda do |_data, _arguments, context|
      GitShellPolicy.new(context[:current_user]).authorize?
    end)

    resolve(lambda do |data, arguments, _context|
      policy = RepositoryPolicy.new(data[:user], data[:repository])
      case arguments[:action]
      when 'push'
        policy.write?
      when 'pull'
        policy.show?
      end
    end)
  end

  field :organizationalUnit, Types::OrganizationalUnitType do
    description 'The organizational unit for the given ID'

    argument :id, !types.ID, as: :slug do
      description 'ID of the organizational unit'
    end

    resolve(lambda do |_root, arguments, _context|
      OrganizationalUnit.first(slug: arguments[:slug])
    end)
  end

  field :repository, Types::RepositoryType do
    description 'The repository for the given ID'

    argument :id, !types.ID, as: :slug do
      description 'ID of the repository'
    end

    authorize :show

    resource(lambda do |_root, arguments, _context|
      RepositoryCompound.first(slug: arguments[:slug])
    end)

    resolve ->(repo, _arguments, _context) { repo }
  end

  field :search, !Types::SearchResultType do
    description 'Search Ontohub'

    argument :query, !types.String do
      description 'The query string'
    end

    resolve(lambda do |_root, arguments, _context|
      SearchResolver.new(arguments[:query]).call
    end)
  end

  field :version, !Types::VersionType do
    description 'The version of the running backend'

    resolve(lambda do |_root, _arguments, _context|
      Version.new(Version::VERSION)
    end)
  end

  field :language, Types::LanguageType do
    description 'A Language for the given ID'

    argument :id, !types.ID do
      description 'The ID of the Langauge'
    end

    resolve(lambda do |_root, arguments, _context|
      Language.first(slug: arguments['id'])
    end)
  end

  field :languageMapping, Types::LanguageMappingType do
    description 'A LanguageMapping for the given ID'

    argument :id, !types.Int do
      description 'The ID of the LangaugeMapping'
    end

    resolve(lambda do |_root, arguments, _context|
      LanguageMapping.first(id: arguments['id'])
    end)
  end

  field :logic, Types::LogicType do
    description 'A Logic for the given ID'

    argument :id, !types.ID do
      description 'The ID of the Langauge'
    end

    resolve(lambda do |_root, arguments, _context|
      Logic.first(slug: arguments['id'])
    end)
  end

  field :logicMapping, Types::LogicMappingType do
    description 'A LogicMapping for the given ID'

    argument :id, !types.ID do
      description 'The ID of the LogicMapping'
    end

    resolve(lambda do |_root, arguments, _context|
      LogicMapping.first(slug: arguments['id'])
    end)
  end

  field :serialization, Types::SerializationType do
    description 'A Serialization for the given ID'

    argument :id, !types.ID do
      description 'The ID of the Serialization'
    end

    resolve(lambda do |_root, arguments, _context|
      Serialization.first(slug: arguments['id'])
    end)
  end

  field :signature, Types::SignatureType do
    description 'A Signature'

    argument :id, !types.Int do
      description 'The id of the Signature'
    end

    resource!(lambda do |_root, arguments, _context|
      Signature.first(id: arguments['id'])
    end)

    not_found_unless :show

    authorize :show

    resolve ->(signature, _arguments, _context) { signature }
  end

  field :signatureMorphism, Types::SignatureMorphismType do
    description 'A SignatureMorphism'

    argument :id, !types.Int do
      description 'The id of the SignatureMorphism'
    end

    resource!(lambda do |_root, arguments, _context|
      SignatureMorphism.first(id: arguments['id'])
    end)

    not_found_unless :show

    authorize :show

    resolve ->(signature_morphism, _arguments, _context) { signature_morphism }
  end

  field :reasoningAttempt, Types::ReasoningAttemptType do
    description 'A ReasoningAttempt'

    argument :id, !types.Int do
      description 'The id of the ReasoningAttempt'
    end

    resource!(lambda do |_root, arguments, _context|
      ReasoningAttempt.first(id: arguments['id'])
    end)

    not_found_unless :show

    authorize :show

    resolve ->(reasoning_attempt, _arguments, _context) { reasoning_attempt }
  end

  field :reasoner, Types::ReasonerType do
    description 'A Reasoner'

    argument :id, !types.ID do
      description 'The id of the Reasoner'
    end

    resolve(lambda do |_root, arguments, _context|
      Reasoner.first(slug: arguments['id'])
    end)
  end

  field :reasonerConfiguration, Types::ReasonerConfigurationType do
    description 'A ReasonerConfiguration'

    argument :id, !types.Int do
      description 'The id of the ReasonerConfiguration'
    end

    resource!(lambda do |_root, arguments, _context|
      ReasonerConfiguration.first(id: arguments['id'])
    end)

    not_found_unless :show

    authorize :show

    resolve ->(configuration, _arguments, _context) { configuration }
  end

  field :generatedAxiom, Types::GeneratedAxiomType do
    description 'A GeneratedAxiom'

    argument :id, !types.Int do
      description 'The id of the GeneratedAxiom'
    end

    resource!(lambda do |_root, arguments, _context|
      GeneratedAxiom.first(id: arguments['id'])
    end)

    not_found_unless :show

    authorize :show

    resolve ->(generated_axiom, _arguments, _context) { generated_axiom }
  end

  field :premiseSelection, Types::PremiseSelectionType do
    description 'A PremiseSelection'

    argument :id, !types.Int do
      description 'The id of the PremiseSelection'
    end

    resource!(lambda do |_root, arguments, _context|
      PremiseSelection.first(id: arguments['id'])
    end)

    not_found_unless :show

    authorize :show

    resolve ->(premise_selection, _arguments, _context) { premise_selection }
  end
end
