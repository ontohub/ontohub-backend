# frozen_string_literal: true

# Methods that should be in Types::ConjectureType, but cannot be there
# because of https://github.com/rmosolgo/graphql-ruby/issues/1067
# rubocop:disable Style/ClassAndModuleChildren
module Types::ConjectureMethods
  # rubocop:enable Style/ClassAndModuleChildren
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.get(scope)
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # Instead of
    # implements Types::SentenceType, inherit: true
    # we need to use
    Types::SentenceMethods.get(scope)
    # because of https://github.com/rmosolgo/graphql-ruby/issues/1067

    scope.field :action, !Types::ActionType do
      description 'Information about the (to be) performed action'
    end

    scope.field :proofStatus, !Types::ProofStatusEnum do
      description 'The proof status of this Conjecture'
      property :proof_status
    end

    scope.field :proofAttempts, !scope.types[!Types::ProofAttemptType] do
      description 'The attempts to prove this Conjecture'

      argument :limit, types.Int do
        description 'Maximum number of entries to list'
        default_value 20
      end

      argument :skip, types.Int do
        description 'Skip the first n entries'
        default_value 0
      end

      resolve(lambda do |conjecture, arguments, _context|
        conjecture.proof_attempts_dataset.
          order(Sequel[:reasoning_attempts][:id]).
          limit(arguments['limit'], arguments['skip'])
      end)
    end
  end
end
