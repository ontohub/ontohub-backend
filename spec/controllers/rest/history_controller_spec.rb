# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rest::HistoryController do
  let!(:repository) { create :repository_compound, :not_empty }
  let!(:user) { repository.owner }
  let!(:path) { repository.git.ls_files(revision).first }
  let!(:revision) { repository.git.default_branch }

  context 'successful (without revision)' do
    describe 'action: index' do
      before do
        get :index, params: {organizational_unit_id: user.to_param,
                              repository_id:
                              repository.to_param.sub(%r{\A[^/]*/}, ''),
                              path: path}
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
      it 'finds the repository' do
        expect(response_data['repository']).not_to be(nil)
      end
    end
  end

  context 'successful (with revision)' do
    describe 'action: index' do
      before do
        get :index, params: {organizational_unit_id: user.to_param,
                            repository_id:
                              repository.to_param.sub(%r{\A[^/]*/}, ''),
                            path: path,
                            revision: revision}
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
      it 'finds the repository' do
        expect(response_data['repository']['log']).not_to be(nil)
      end
    end
  end

  context 'failing because of bad params (without revision)' do
    describe 'action: index' do
      before do
        get :index, params: {organizational_unit_id: '', repository_id: '',
                            path: ''}
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
      it 'does not find the repository' do
        expect(response_data['repository']).to be(nil)
      end
    end
  end

  context 'failing because of bad params (with revision)' do
    describe 'action: index' do
      before do
        get :index, params: {organizational_unit_id: '', repository_id: '',
                            path: '', revision: ''}
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
      it 'does not find the repository' do
        expect(response_data['repository']).to be(nil)
      end
    end
  end
end
