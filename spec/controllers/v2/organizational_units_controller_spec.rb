# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::OrganizationalUnitsController do
  let!(:user) { create :user }
  let!(:organization) { create :organization }

  before do
    organization.add_member(user)
    organization.add_member(create(:user))
  end

  context 'subject: user' do
    subject { user }

    describe 'GET show' do
      context 'successful' do
        before { get :show, params: {slug: subject.slug} }
        it { expect(response).to have_http_status(:ok) }
        it { expect(response).to match_response_schema('v2', 'jsonapi') }
        it { expect(response).to match_response_schema('v2', 'user_show') }
      end
    end
  end

  context 'subject: organization' do
    subject { organization }

    describe 'GET show' do
      context 'successful' do
        before { get :show, params: {slug: subject.slug} }
        it { expect(response).to have_http_status(:ok) }
        it { expect(response).to match_response_schema('v2', 'jsonapi') }
        it do
          expect(response).to match_response_schema('v2', 'organization_show')
        end
      end
    end
  end
end