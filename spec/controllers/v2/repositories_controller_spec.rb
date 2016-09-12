# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::RepositoriesController do
  let!(:repository) { create :repository }
  let(:bad_slug) { "notThere-#{repository.slug}" }

  describe 'GET index' do
    before { get :index }
    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to match_response_schema('v2', 'jsonapi', false) }
    it { expect(response).to match_response_schema('v2', 'repository_index') }
  end

  describe 'GET show' do
    context 'successful' do
      before { get :show, params: {slug: repository.slug} }
      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to match_response_schema('v2', 'jsonapi', false) }
      it { expect(response).to match_response_schema('v2', 'repository_show') }
    end

    context 'failing with an inexistent URL' do
      before { get :show, params: {slug: bad_slug} }
      it { expect(response).to have_http_status(:not_found) }
      it { expect(response.body.strip).to be_empty }
    end
  end

  describe 'POST create' do
    context 'successful' do
      let(:name) { "new-#{repository.name}" }
      before do
        data = {attributes:
                {name: name,
                 description: "New #{repository.description}"}}
        post :create, params: {data: data}
      end
      it { expect(response).to have_http_status(:created) }
      it { expect(response).to match_response_schema('v2', 'jsonapi', false) }
      it do
        expect(response).to match_response_schema('v2', 'repository_create')
      end
      it 'creates the repository' do
        expect(Repository.find(name: name)).not_to be(nil)
      end
    end

    context 'failing' do
      context 'with invalid data' do
        let(:name) { 'n' }
        before do
          data = {attributes:
                  {name: name,
                   description: "New #{repository.description}"}}
          post :create, params: {data: data}
        end
        it { expect(response).to have_http_status(:unprocessable_entity) }
        it { expect(response).to match_response_schema('v2', 'jsonapi', false) }
        it do
          expect(response).to match_response_schema('v2', 'validation_error')
        end
        it 'does not create the repository' do
          expect(Repository.find(name: name)).to be(nil)
        end
      end
    end
  end

  describe 'PATCH update' do
    let!(:data) do
      {attributes: {name: "changed-#{repository.name}",
                    description: "Changed #{repository.description}"}}
    end

    context 'successful' do
      before { patch :update, params: {slug: repository.slug, data: data} }
      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to match_response_schema('v2', 'jsonapi', false) }
      it do
        expect(response).to match_response_schema('v2', 'repository_update')
      end
      it { expect { repository.reload }.to change { repository.name } }
      it { expect { repository.reload }.to change { repository.description } }
    end

    context 'failing' do
      context 'with an inexistent URL' do
        before { patch :update, params: {slug: bad_slug, data: data} }
        it { expect(response).to have_http_status(:not_found) }
        it { expect(response.body.strip).to be_empty }
        it 'does not change the repository' do
          expect { repository.reload }.not_to change { repository.name }
        end
      end

      context 'with unpermitted params' do
        before do
          new_slug = "changed-#{repository.slug}"
          patch :update, params: {slug: repository.slug,
                                  data: data.merge(slug: new_slug)}
        end
        it { expect(response).to have_http_status(:ok) }
        it { expect(response).to match_response_schema('v2', 'jsonapi', false) }
        it do
          expect(response).to match_response_schema('v2', 'repository_update')
        end
        it 'does not change the repository' do
          expect { repository.reload }.not_to change { repository.slug }
        end
      end

      context 'with invalid data' do
        before do
          patch :update, params: {slug: repository.slug,
                                  data: data.merge(attributes: {name: 'n'})}
        end
        it { expect(response).to have_http_status(:unprocessable_entity) }
        it { expect(response).to match_response_schema('v2', 'jsonapi', false) }
        it do
          expect(response).to match_response_schema('v2', 'validation_error')
        end
        it 'does not change the repository' do
          expect { repository.reload }.not_to change { repository.name }
        end
      end
    end
  end

  describe 'DELETE destroy' do
    context 'successful' do
      before { delete :destroy, params: {slug: repository.slug} }
      it { expect(response).to have_http_status(:no_content) }
      it { expect(response.body.strip).to be_empty }
      it 'deletes the repository' do
        expect(Repository.find(slug: repository.slug)).to be(nil)
      end
    end

    context 'failing' do
      before { delete :destroy, params: {slug: bad_slug} }
      it { expect(response).to have_http_status(:not_found) }
      it { expect(response.body.strip).to be_empty }
      it 'does not delete the repository' do
        expect(Repository.find(slug: repository.slug)).not_to be(nil)
      end
    end
  end
end
