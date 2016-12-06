# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::OrganizationsController do
  subject { create :organization }
  let(:bad_slug) { "notThere-#{subject.slug}" }

  describe 'GET show' do
    context 'successful' do
      before { get :show, params: {slug: subject.slug} }
      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to match_response_schema('v2', 'jsonapi') }
      it do
        expect(response).to match_response_schema('v2', 'organization_show')
      end
    end

    context 'failing with an inexistent URL' do
      before { get :show, params: {slug: bad_slug} }
      it { expect(response).to have_http_status(:not_found) }
      it { expect(response.body.strip).to be_empty }
    end
  end
end
