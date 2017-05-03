# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::UsersController do
  subject { create :user }
  let!(:organization) { create :organization }

  before do
    organization.add_member(subject)
    organization.add_member(create(:user))
  end
  let(:bad_slug) { "notThere-#{subject.slug}" }
  let(:bad_name) { "notThere-#{subject.name}" }

  describe 'GET show' do
    context 'successful' do
      before { get :show, params: {slug: subject.slug} }
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_api }
    end

    context 'failing with an inexistent URL' do
      before { get :show, params: {slug: bad_slug} }
      it { expect(response).to have_http_status(:not_found) }
      it { expect(response.body.strip).to be_empty }
    end
  end

  describe 'GET show_by_name' do
    context 'successful' do
      before { get :show_by_name, params: {name: subject.name} }
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_api }
    end

    context 'failing with an inexistent URL' do
      before { get :show_by_name, params: {name: bad_name} }
      it { expect(response).to have_http_status(:not_found) }
      it { expect(response.body.strip).to be_empty }
    end
  end
end
