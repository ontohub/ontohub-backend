# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::RepositoriesController do
  let!(:repository) { create :repository }
  let!(:namespace) { repository.namespace }

  let(:bad_slug) { "notThere-#{repository.slug}" }

  describe 'GET index' do
    let!(:another_repository) { create :repository, namespace: namespace }
    let!(:other_namespace) { create :namespace }
    let!(:other_repository) { create :repository, namespace: other_namespace }

    before { get :index, params: {namespace_slug: namespace.to_param} }

    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to match_response_schema('v2', 'jsonapi') }
    it { expect(response).to match_response_schema('v2', 'repository_index') }

    it 'returns only repositories from the requested namespace' do
      expect(JSON.parse(response.body)['data'].size).
        to eq(namespace.repositories.count)
    end
  end

  describe 'GET show' do
    context 'successful' do
      before do
        get :show, params: {namespace_slug: namespace.to_param,
                            slug: repository.slug}
      end
      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to match_response_schema('v2', 'jsonapi') }
      it { expect(response).to match_response_schema('v2', 'repository_show') }
    end

    context 'failing with an inexistent URL' do
      before do
        get :show, params: {namespace_slug: namespace.to_param,
                            slug: bad_slug}
      end
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
                 description: "New #{repository.description}",
                 content_type: repository.content_type,
                 public_access: repository.public_access},
                relationships:
                 {namespace:
                  {data:
                   {type: 'namespaces', id: repository.namespace.to_param}}}}
        post :create, params: {data: data}
      end
      it { expect(response).to have_http_status(:created) }
      it { expect(response).to match_response_schema('v2', 'jsonapi') }
      it do
        expect(response).to match_response_schema('v2', 'repository_create')
      end
      it 'creates the repository' do
        expect(Repository.find(name: name)).not_to be(nil)
      end
    end

    context 'failing' do
      context 'with invalid data' do
        # Name too short
        let(:name) { 'n' }
        before do
          data = {attributes:
                  {name: name,
                   description: "New #{repository.description}",
                   content_type: repository.content_type,
                   public_access: repository.public_access},
                  relationships:
                   {namespace:
                    {data:
                     {type: 'namespaces', id: repository.namespace.to_param}}}}
          post :create, params: {data: data}
        end
        it { expect(response).to have_http_status(:unprocessable_entity) }
        it { expect(response).to match_response_schema('v2', 'jsonapi') }
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
      {attributes: {description: "Changed #{repository.description}"}}
    end

    context 'successful' do
      before do
        patch :update, params: {namespace_slug: namespace.to_param,
                                slug: repository.slug, data: data}
      end
      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to match_response_schema('v2', 'jsonapi') }
      it do
        expect(response).to match_response_schema('v2', 'repository_update')
      end
      it { expect { repository.reload }.to change { repository.description } }
    end

    context 'failing' do
      context 'with an inexistent URL' do
        before do
          patch :update, params: {namespace_slug: namespace.to_param,
                                  slug: bad_slug, data: data}
        end
        it { expect(response).to have_http_status(:not_found) }
        it { expect(response.body.strip).to be_empty }
        it 'does not change the repository' do
          expect { repository.reload }.not_to change { repository.name }
        end
      end

      context 'with unpermitted params' do
        before do
          new_name = "changed-#{repository.name}"
          patch :update, params: {namespace_slug: namespace.to_param,
                                  slug: repository.slug,
                                  data: data.merge(name: new_name)}
        end
        it { expect(response).to have_http_status(:ok) }
        it { expect(response).to match_response_schema('v2', 'jsonapi') }
        it do
          expect(response).to match_response_schema('v2', 'repository_update')
        end
        it 'does not change the repository' do
          expect { repository.reload }.not_to change { repository.slug }
        end
      end
    end

    context 'with invalid data' do
      let(:bad_content_type) { "Bad-#{repository.content_type}" }
      before do
        patch :update, params: {slug: repository.slug,
                                data: data.
                                  merge(attributes: data[:attributes].
                                    merge(content_type: bad_content_type))}
      end
      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to match_response_schema('v2', 'jsonapi') }
      it do
        expect(response).to match_response_schema('v2', 'validation_error')
      end
      it 'does not create the repository' do
        expect(Repository.find(slug: repository.slug)).to eq(repository)
      end
    end
  end

  describe 'DELETE destroy' do
    context 'successful' do
      before do
        delete :destroy, params: {namespace_slug: namespace.to_param,
                                  slug: repository.slug}
      end
      it { expect(response).to have_http_status(:no_content) }
      it { expect(response.body.strip).to be_empty }
      it 'deletes the repository' do
        expect(Repository.find(slug: repository.slug)).to be(nil)
      end
    end

    context 'failing' do
      before do
        delete :destroy, params: {namespace_slug: namespace.to_param,
                                  slug: bad_slug}
      end
      it { expect(response).to have_http_status(:not_found) }
      it { expect(response.body.strip).to be_empty }
      it 'does not delete the repository' do
        expect(Repository.find(slug: repository.slug)).not_to be(nil)
      end
    end
  end
end
