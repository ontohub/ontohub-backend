# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rest::ApplicationController do
  describe 'action: no_op' do
    before { get :no_op }
    it { expect(response).to have_http_status(:no_content) }
    it { expect(response.body).to be_blank }
  end
end
