# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Repository::RemoveRepositoryMemberMutation do
  let!(:current_user) { create :user }
  let!(:repository) { create :repository_compound, owner: current_user }

  let!(:user) { create :user }

  before do
    repository.add_member(user, 'write')
  end

  let(:context) { {current_user: current_user} }
  let(:variables) do
    {'user' => user.to_param,
     'repository' => repository.to_param}
  end

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    mutation RemoveRepositoryMember($repository: ID!, $user: ID!) {
      removeRepositoryMember(repository: $repository, member: $user)
    }
    QUERY
  end

  subject { result }

  context 'Successful removal' do
    it 'returns true' do
      expect(subject).to match('data' => {'removeRepositoryMember' => true})
    end
  end

  context 'User does not exist' do
    let(:variables) do
      {'user' => "bad-#{user.to_param}",
       'repository' => repository.to_param}
    end

    it 'returns false' do
      expect(subject).to match('data' => {'removeRepositoryMember' => false})
    end
  end

  context 'User is not a member' do
    let(:variables) do
      {'user' => create(:user).to_param,
       'repository' => repository.to_param}
    end

    it 'returns false' do
      expect(subject).to match('data' => {'removeRepositoryMember' => false})
    end
  end

  context 'Unable to see the repository' do
    let!(:repository) { create :repository_compound, :private }
    let(:context) { {} }

    it 'returns an error' do
      expect(subject.to_h).
        to match('data' => {'removeRepositoryMember' => nil},
                 'errors' =>
                   include(include('message' => 'resource not found')))
    end
  end

  context 'Not signed in' do
    let(:context) { {} }

    it 'returns an error' do
      expect(subject.to_h).
        to match('data' => {'removeRepositoryMember' => nil},
                 'errors' =>
                   include(include('message' =>
                                     "You're not authorized to do this")))
    end
  end
end
