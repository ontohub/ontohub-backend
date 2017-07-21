# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V3::OrganizationalUnitsController do
  let!(:user) { create :user }
  let!(:organization) { create :organization }

  before do
    organization.add_member(user)
    organization.add_member(create(:user))
  end

  context 'subject: user' do
    subject { user }

    describe 'action: show' do
      before { get :show, params: {slug: subject.slug} }
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
    end
  end

  context 'subject: organization' do
    subject { organization }

    describe 'action: show' do
      before { get :show, params: {slug: subject.slug} }
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
    end
  end
end
