# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::SearchController do
  let(:num_objects) { 2 }
  before do
    num_objects.times { create :user }
    User.each do |user|
      create :repository, owner: user
      create :organization
    end
  end

  describe 'GET search' do
    context 'successful' do
      before { get :search }
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_api }

      it 'presents the correct results_count' do
        expect(response_data['attributes']['results_count']).
          to eq(3 * num_objects)
      end

      it 'presents the correct repositories_count' do
        expect(response_data['attributes']['repositories_count']).
          to eq(num_objects)
      end

      it 'presents the correct organizational_units_count' do
        expect(response_data['attributes']['organizational_units_count']).
          to eq(2 * num_objects)
      end

      it 'lists the correct number of repositories' do
        expect(response_data['relationships']['repositories']['data'].size).
          to eq(num_objects)
      end

      it 'lists the correct number of organizational_units' do
        org_units = response_data['relationships']['organizational_units']
        expect(org_units['data'].size).to eq(2 * num_objects)
      end
    end
  end
end
