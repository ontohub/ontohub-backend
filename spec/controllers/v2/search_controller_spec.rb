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
      it { expect(response).to match_response_schema('v2', 'jsonapi') }
      it { expect(response).to match_response_schema('v2', 'search_search') }

      it 'presents the correct results_count' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['results_count']).
          to eq(3 * num_objects)
      end

      it 'presents the correct repositories_count' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['repositories_count']).
          to eq(num_objects)
      end

      it 'presents the correct organizational_units_count' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['organizational_units_count']).
          to eq(2 * num_objects)
      end

      it 'lists the correct number of repositories' do
        json = JSON.parse(response.body)
        expect(json['data']['relationships']['repositories']['data'].size).
          to eq(num_objects)
      end

      it 'lists the correct number of organizational_units' do
        json = JSON.parse(response.body)
        org_units = json['data']['relationships']['organizational_units']
        expect(org_units['data'].size).to eq(2 * num_objects)
      end
    end
  end
end
