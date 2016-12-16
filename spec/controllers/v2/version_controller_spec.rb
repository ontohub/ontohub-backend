# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::VersionController do
  describe 'GET show' do
    before { get :show }
    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to match_response_schema('v2', 'jsonapi') }
    it { expect(response).to match_response_schema('v2', 'version_show') }
  end
end
