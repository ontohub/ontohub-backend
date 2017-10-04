# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/resend_unlock_account_email'

RSpec.describe Mutations::Account::ResendUnlockAccountEmailMutation,
  type: :mailer, no_transaction: true, stub_abstract_devise_mutation: true do
  let!(:user) { create :user }

  let(:context) { {} }
  let(:variables) { {} }

  let(:result) do
    perform_enqueued_jobs do
      OntohubBackendSchema.execute(
        query_string,
        context: context,
        variables: variables
      )
    end
  end

  let(:query_string) do
    <<-QUERY
    mutation ResendUnlockAccountEmail($email: String!) {
      resendUnlockAccountEmail(email: $email)
    }
    QUERY
  end

  subject { result }

  before do
    UsersMailer.deliveries.clear
    queue_adapter.performed_jobs = []
  end

  context 'User exists' do
    let(:variables) { {'email' => user.email} }

    context 'and is locked' do
      before do
        user.lock_access!
        queue_adapter.performed_jobs = []
        UsersMailer.deliveries.clear
        subject
      end

      it 'returns true' do
        expect(subject['data']['resendUnlockAccountEmail']).to be(true)
      end
      it_behaves_like 'an unlock account email sender'
    end

    context 'and is not locked' do
      it 'returns true' do
        expect(subject['data']['resendUnlockAccountEmail']).to be(true)
      end

      it 'does not send an email' do
        expect(performed_jobs).to be_empty
        expect(UsersMailer.deliveries).to be_empty
      end
    end
  end

  context 'User does not exist' do
    let(:variables) { {'email' => "bad-#{user.email}"} }

    it 'returns true' do
      expect(subject['data']['resendUnlockAccountEmail']).to be(true)
    end

    it 'does not send an email' do
      expect(performed_jobs).to be_empty
      expect(UsersMailer.deliveries).to be_empty
    end
  end
end
