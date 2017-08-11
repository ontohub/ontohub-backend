# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/confirmation_email'

RSpec.describe 'resendConfirmationEmail mutation',
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
    mutation ResendConfirmationEmail($email: String!) {
      resendConfirmationEmail(email: $email)
    }
    QUERY
  end

  subject { result }

  before do
    queue_adapter.performed_jobs = []
    subject
  end

  context 'User exists' do
    let(:variables) { {'email' => user.email} }

    it 'returns true' do
      expect(subject['data']['resendConfirmationEmail']).to be(true)
    end
    it_behaves_like 'a confirmation email sender'
  end

  context 'User does not exist' do
    let(:variables) { {'email' => "bad-#{user.email}"} }

    it 'returns true' do
      expect(subject['data']['resendConfirmationEmail']).to be(true)
    end

    it 'does not send an email' do
      expect(UsersMailer.deliveries).to be_empty
    end
  end
end
