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
        it do |example|
          expect([example, response]).to comply_with_api('users/get_show')
        end
      end
    end
  end

  context 'subject: organization' do
    subject { organization }

    describe 'GET show' do
      context 'successful' do
        before { get :show, params: {slug: subject.slug} }
        it { expect(response).to have_http_status(:ok) }
        it do |example|
          expect([example, response]).
            to comply_with_api('organizations/get_show')
        end
      end
    end
  end
end
