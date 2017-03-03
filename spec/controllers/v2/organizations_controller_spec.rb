# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::OrganizationsController do
  subject { create :organization }
  let(:bad_slug) { "notThere-#{subject.slug}" }

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
end
