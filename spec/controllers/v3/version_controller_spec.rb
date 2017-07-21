# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V3::VersionController do
  describe 'GET show' do
    before do
      Version # rubocop:disable Lint/Void
      stub_const('Version::VERSION', '0.0.0-12-gabcdefg')
    end
    before { get :show }
    it { expect(response).to have_http_status(:ok) }
    it { |example| expect([example, response]).to comply_with_api(nil, false) }
  end
end
