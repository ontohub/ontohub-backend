# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rest::BranchesController do
  let!(:repository) { create :repository_compound }
  let!(:user) { repository.owner }

  context 'successful' do
    describe 'action: index' do
      before do
        get :index, params: {organizational_unit_id: user.to_param,
                             repository_id:
                             repository.to_param.sub(%r{\A[^/]*/}, '')}
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
      it 'finds the repository' do
        expect(response_data['repository']).not_to be(nil)
      end
    end

    describe 'action: show' do
      before do
        get :show, params: {organizational_unit_id: user.to_param,
                            repository_id:
                              repository.to_param.sub(%r{\A[^/]*/}, ''),
                            name: repository.git.default_branch}
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
      it 'finds the correct branch' do
        expect(response_data['repository']['branch']['name']).
          to eq(repository.git.default_branch)
      end
    end
  end

  context 'failing because repository is private' do
    let!(:private_repo) { create :repository_compound, :private }

    describe 'action: index' do
      before do
        get :index, params: {organizational_unit_id: user.to_param,
                             repository_id:
                             private_repo.to_param.sub(%r{\A[^/]*/}, '')}
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
      it 'does not find the respository' do
        expect(response_data['respository']).to be(nil)
      end
    end

    describe 'action: show' do
      before do
        get :show, params: {organizational_unit_id: user.to_param,
                            repository_id:
                            private_repo.to_param.sub(%r{\A[^/]*/}, ''),
                            name: private_repo.git.default_branch}
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
      it 'does not return the repository' do
        expect(response_data['repository']).to be(nil)
      end
    end
  end

  context 'failing because of bad params' do
    describe 'action: index' do
      before do
        get :index, params: {organizational_unit_id: '', repository_id: ''}
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
      it 'does not find the respository' do
        expect(response_data['respository']).to be(nil)
      end
    end

    describe 'action: show' do
      before do
        get :show, params: {organizational_unit_id: user.to_param,
                            repository_id:
                            repository.to_param.sub(%r{\A[^/]*/}, ''),
                            name: ''}
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
      it 'does not find the branch' do
        expect(response_data['repository']['branch']).to be(nil)
      end
    end
  end
end
