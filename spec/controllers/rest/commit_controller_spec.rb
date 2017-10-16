# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rest::CommitController do
  let!(:repository) { create :repository_compound, :not_empty }
  let!(:user) { repository.owner }
  let!(:commit) { repository.git.commit(repository.git.default_branch) }
  let!(:revision) { repository.git.default_branch }

  context 'successful (without revision)' do
    describe 'action: show' do
      before do
        get :show, params: {organizational_unit_id: user.to_param,
                            repository_id:
                              repository.to_param.sub(%r{\A[^/]*/}, '')}
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
      it 'finds the commit id' do
        expect(response_data['repository']['commit']['id']).to eq(commit.id)
      end
    end
  end

  context 'successful (with revision)' do
    describe 'action: show' do
      before do
        get :show, params: {organizational_unit_id: user.to_param,
                            repository_id:
                              repository.to_param.sub(%r{\A[^/]*/}, ''),
                            revision: revision}
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
      it 'finds the commit id' do
        expect(response_data['repository']['commit']['id']).to eq(commit.id)
      end
    end
  end

  context 'failing because of bad params (without revision' do
    describe 'action: show' do
      before do
        get :show, params: {organizational_unit_id: '', repository_id: ''}
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
      it 'does not find the repository' do
        expect(response_data['repository']).to be(nil)
      end
    end
  end

  context 'failing because of bad params (with revision)' do
    describe 'action: show' do
      before do
        get :show, params: {organizational_unit_id: '', repository_id: '',
                            revision: ''}
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
      it 'does not find the repository' do
        expect(response_data['repository']).to be(nil)
      end
    end
  end
end
