# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rest::TagsController do
  let!(:repository) { create :repository_compound, :not_empty }
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
      let!(:tag_name) { '1.0' }
      before do
        repository.git.create_tag(tag_name, repository.git.default_branch)
        get :show, params: {organizational_unit_id: user.to_param,
                            repository_id:
                              repository.to_param.sub(%r{\A[^/]*/}, ''),
                            name: tag_name}
      end
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
      it 'finds the correct tag' do
        expect(response_data['repository']['tag']['name']).to eq(tag_name)
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
      it 'does not find the repository' do
        expect(response_data['repository']).to be(nil)
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
      it 'does not find the tag' do
        expect(response_data['repository']['tag']).to be(nil)
      end
    end
  end
end
