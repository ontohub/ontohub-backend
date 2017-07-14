# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::RepositoriesController do
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  context 'owner: user' do

    let!(:owner) { create :user }
    let!(:repository) { create :repository, public_access: true, owner: owner }

    let(:bad_slug) { "notThere-#{repository.slug}" }

    describe 'GET index' do
      let!(:another_repository) { create :repository, public_access: false, owner: owner }
      let!(:other_owner) { create :user }
      let!(:other_repository) { create :repository, public_access: true, owner: other_owner }

      context "owner's repositories" do
        before { get :index, params: {user_slug: owner.to_param} }

        it { expect(response).to have_http_status(:ok) }
        it { |example| expect([example, response]).to comply_with_api }

        it 'returns only the public repositories from the user' do
          expect(response_data.size).to eq(owner.repositories_dataset.where(public_access: true).count)
        end
      end

      context 'returns only the filtered repositories when signed in' do
        before do
          sign_in(owner)
          create :repository, public_access: false, owner: owner
          create :repository, public_access: false, owner: other_owner
        end

        context 'request owner repositories' do
          before { get :index, params: {user_slug: owner.to_param} }

          it 'returns all repositories from owner' do
            expect(response_data.map{ |repo| repo['id']}).to match_array(owner.repositories.map(&:to_param))
          end
        end

        context 'request other owner repositories' do
          before { get :index, params: {user_slug: other_owner.to_param} }

          it 'returns all repositories from other owner' do
            expect(response_data.map{ |repo| repo['id']}).to match_array(other_owner.repositories_dataset.where(public_access: true).map(&:to_param))
          end
        end
      end
    end

    describe 'GET show' do
      context 'successful' do
        before do
          get :show, params: {user_slug: owner.to_param,
                              slug: repository.slug}
        end
        it { expect(response).to have_http_status(:ok) }
        it { |example| expect([example, response]).to comply_with_api }
      end

      context 'failing with an inexistent URL' do
        before do
          get :show, params: {user_slug: owner.to_param,
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
                    {owner:
                      {data:
                        {type: 'users', id: repository.owner.to_param}}}}
          post :create, params: {data: data}
        end
        it { expect(response).to have_http_status(:created) }
        it { |example| expect([example, response]).to comply_with_api }
        it 'creates the repository' do
          expect(Repository.find(name: name)).not_to be(nil)
        end
        it 'creates the git repository' do
          repository = Repository.find(name: name)
          git_path = Settings.data_directory.join('git',
                                                  "#{repository.to_param}.git")
          expect(Gitlab::Git::Wrapper.new(git_path).repo_exists?).to be(true)
        end
        it 'sets the correct url' do
          found_repository = Repository.find(name: name)
          expect(found_repository.url_path).
            to eq("/#{found_repository.to_param}")
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
                      {owner:
                        {data:
                          {type: 'users', id: repository.owner.to_param}}}}
            post :create, params: {data: data}
          end
          it { expect(response).to have_http_status(:unprocessable_entity) }
          it do |example|
            expect([example, response]).to comply_with_api('validation_error')
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
          patch :update, params: {user_slug: owner.to_param,
                                  slug: repository.slug, data: data}
        end
        it { expect(response).to have_http_status(:ok) }
        it { |example| expect([example, response]).to comply_with_api }
        it do
          expect { repository.reload }.to(change { repository.description })
        end
      end

      context 'failing' do
        context 'with an inexistent URL' do
          before do
            patch :update, params: {user_slug: owner.to_param,
                                    slug: bad_slug, data: data}
          end
          it { expect(response).to have_http_status(:not_found) }
          it { expect(response.body.strip).to be_empty }
          it 'does not change the repository' do
            expect { repository.reload }.not_to(change { repository.name })
          end
        end

        context 'with unpermitted params' do
          before do
            new_name = "changed-#{repository.name}"
            patch :update, params: {user_slug: owner.to_param,
                                    slug: repository.slug,
                                    data: data.merge(name: new_name)}
          end
          it { expect(response).to have_http_status(:ok) }
          it { |example| expect([example, response]).to comply_with_api }
          it 'does not change the repository' do
            expect { repository.reload }.not_to(change { repository.slug })
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
        it do |example|
          expect([example, response]).to comply_with_api('validation_error')
        end
        it 'does not create the repository' do
          expect(Repository.find(slug: repository.slug)).to eq(repository)
        end
      end
    end

    describe 'DELETE destroy' do
      context 'successful' do
        before do
          delete :destroy, params: {user_slug: owner.to_param,
                                    slug: repository.slug}
        end
        it { expect(response).to have_http_status(:no_content) }
        it { expect(response.body.strip).to be_empty }
        it 'deletes the repository' do
          expect(Repository.find(slug: repository.slug)).to be(nil)
        end
        it 'deletes the git repository' do
          git_path = Settings.data_directory.join('git',
                                                  "#{repository.to_param}.git")
          expect(Gitlab::Git::Wrapper.new(git_path).repo_exists?).to be(false)
        end
      end

      context 'failing' do
        before do
          delete :destroy, params: {user_slug: owner.to_param,
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

  context 'owner: organization' do
    let!(:owner) { create :organization }
    let!(:repository) { create :repository, public_access: true, owner: owner }

    let(:bad_slug) { "notThere-#{repository.slug}" }

    describe 'GET index' do
      let!(:another_repository) { create :repository, public_access: false, owner: owner }
      let!(:other_owner) { create :organizational_unit }
      let!(:other_repository) { create :repository, owner: other_owner }

      before { get :index, params: {organization_slug: owner.to_param} }

      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_api }

      it 'returns only repositories from the requested organization' do
        expect(response_data.size).to eq(owner.repositories_dataset.where(public_access: true).count)
      end
    end

    describe 'GET show' do
      context 'successful' do
        before do
          get :show, params: {organization_slug: owner.to_param,
                              slug: repository.slug}
        end
        it { expect(response).to have_http_status(:ok) }
        it { |example| expect([example, response]).to comply_with_api }
      end

      context 'failing with an inexistent URL' do
        before do
          get :show, params: {organization_slug: owner.to_param,
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
                    {owner:
                      {data:
                        {type: 'organizations',
                         id: repository.owner.to_param}}}}
          post :create, params: {data: data}
        end
        it { expect(response).to have_http_status(:created) }
        it { |example| expect([example, response]).to comply_with_api }
        it 'creates the repository' do
          expect(Repository.find(name: name)).not_to be(nil)
        end
        it 'sets the correct url' do
          found_repository = Repository.find(name: name)
          expect(found_repository.url_path).
            to eq("/#{found_repository.to_param}")
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
                      {owner:
                        {data:
                          {type: 'organizations',
                           id: repository.owner.to_param}}}}
            post :create, params: {data: data}
          end
          it { expect(response).to have_http_status(:unprocessable_entity) }
          it do |example|
            expect([example, response]).to comply_with_api('validation_error')
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
          patch :update, params: {organization_slug: owner.to_param,
                                  slug: repository.slug, data: data}
        end
        it { expect(response).to have_http_status(:ok) }
        it { |example| expect([example, response]).to comply_with_api }
        it do
          expect { repository.reload }.to(change { repository.description })
        end
      end

      context 'failing' do
        context 'with an inexistent URL' do
          before do
            patch :update, params: {organization_slug: owner.to_param,
                                    slug: bad_slug, data: data}
          end
          it { expect(response).to have_http_status(:not_found) }
          it { expect(response.body.strip).to be_empty }
          it 'does not change the repository' do
            expect { repository.reload }.not_to(change { repository.name })
          end
        end

        context 'with unpermitted params' do
          before do
            new_name = "changed-#{repository.name}"
            patch :update, params: {organization_slug: owner.to_param,
                                    slug: repository.slug,
                                    data: data.merge(name: new_name)}
          end
          it { expect(response).to have_http_status(:ok) }
          it { |example| expect([example, response]).to comply_with_api }
          it 'does not change the repository' do
            expect { repository.reload }.not_to(change { repository.slug })
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
        it do |example|
          expect([example, response]).to comply_with_api('validation_error')
        end
        it 'does not create the repository' do
          expect(Repository.find(slug: repository.slug)).to eq(repository)
        end
      end
    end

    describe 'DELETE destroy' do
      context 'successful' do
        before do
          delete :destroy, params: {organization_slug: owner.to_param,
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
          delete :destroy, params: {organization_slug: owner.to_param,
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
end
