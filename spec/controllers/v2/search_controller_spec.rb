# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::SearchController do
  describe 'GET search' do
    context 'successful' do
      before { get :search }
      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to match_response_schema('v2', 'jsonapi') }
      it { expect(response).to match_response_schema('v2', 'search_search') }
    end
  end
end
