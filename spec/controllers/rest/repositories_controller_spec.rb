# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rest::RepositoriesController do
  subject { create :repository_compound }
  let!(:user) { subject.owner }

  context 'successful' do
    describe 'action: index' do
      before do
        get :index, params: {organizational_unit_id: user.to_param}
      end

      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }

      it 'finds the organizational unit' do
        expect(response_data['organizationalUnit']).not_to be(nil)
      end
      it 'finds the repository' do
        expect(response_data['organizationalUnit']['repositories']).
          not_to be(nil)
      end
    end

    describe 'action: show' do
      before do
        get :show,
          params: {organizational_unit_id: user.to_param,
                   repository_id: subject.to_param.sub(%r{\A[^/]*/}, '')}
      end

      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }

      it 'finds the repository' do
        expect(response_data['repository']).not_to be(nil)
      end
    end
  end

  context 'failing because repository is private' do
    subject { create :repository_compound, :private }
    let!(:user) { subject.owner }

    describe 'action: index' do
      before do
        get :index, params: {organizational_unit_id: user.to_param}
      end
      it 'does not return the repository' do
        expect(response_data['organizationalUnit']['repositories']).to be_empty
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
    end

    describe 'action: show' do
      before do
        get :show,
          params: {organizational_unit_id: user.to_param,
                   repository_id: subject.to_param.sub(%r{\A[^/]*/}, '')}
      end
      it 'does not return the repository' do
        expect(response_data['repository']).to be(nil)
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
    end
  end

  context 'failing because of bad params' do
    describe 'action: index' do
      before do
        get :index, params: {organizational_unit_id: ''}
      end
      it 'does not find the organizational unit' do
        expect(response_data['organizationalUnit']).to be(nil)
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
    end

    describe 'action: show' do
      before do
        get :show, params: {organizational_unit_id: '', repository_id: ''}
      end
      it 'does not find the repository' do
        expect(response_data['repository']).to be(nil)
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
    end
  end
end
