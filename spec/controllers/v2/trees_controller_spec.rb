# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'a TreesController on GET show' do
  it { expect(response).to have_http_status(:ok) }
  it { |example| expect([example, response]).to comply_with_api }
end

RSpec.shared_examples 'a TreesController on POST create' do
  it { expect(response).to have_http_status(:created) }
  it { |example| expect([example, response]).to comply_with_api }

  it 'creates a file with the correct content at the path' do
    expect(git.blob(branch, path).data).to eq(content)
  end
end

RSpec.shared_examples 'a failing TreesController on POST create' do
  it { expect(response).to have_http_status(:unprocessable_entity) }
  it do |example|
    expect([example, response]).to comply_with_api('validation_error')
  end

  it 'does not create a file' do
    expect(git.blob(branch, path)).to be(nil)
  end
end

RSpec.shared_examples 'a failing TreesController on PATCH update' do
  it { expect(response).to have_http_status(:unprocessable_entity) }
  it do |example|
    expect([example, response]).to comply_with_api('validation_error')
  end

  it 'does not change the original file' do
    expect(git.blob(branch, path).data).to eq(content)
  end

  it 'does not move the file' do
    expect(git.blob(branch, updated_path)).to be(nil)
  end
end

RSpec.describe V2::TreesController do
  create_user_and_sign_in
  let!(:repository) { create(:repository_compound) }
  let!(:git) { repository.git }
  let!(:branch) { git.default_branch }

  context 'without a ref' do
    describe 'GET show tree' do
      before do
        get :show, params: {repository_slug: repository.to_param, path: '/'}
      end

      it_behaves_like 'a TreesController on GET show'
    end

    describe 'GET show blob' do
      before do
        subpath = git.tree(branch, '/').first.path
        path = git.tree(branch, subpath).first.path
        get :show, params: {repository_slug: repository.to_param,
                            path: path}
      end

      it_behaves_like 'a TreesController on GET show'
    end

    describe 'GET show to non-existent path' do
      before do
        get :show, params: {repository_slug: repository.to_param,
                            path: '/this/path/does-not-exist'}
      end

      it { expect(response).to have_http_status(:not_found) }
    end

    describe 'POST create' do
      let(:path) { generate(:filepath) }
      let(:commit_message) { generate(:commit_message) }
      let(:content) { 'some content' }
      let(:content_encoded) { Base64.strict_encode64(content) }

      context 'successful' do
        before do
          post :create,
            params: {repository_slug: repository.to_param,
                     data: {attributes: {content: content_encoded,
                                         encoding: 'base64',
                                         commit_message: commit_message,
                                         path: path}}}
        end
        it_behaves_like 'a TreesController on POST create'
      end

      context 'failing' do
        context 'because no content is given' do
          before do
            post :create,
              params: {repository_slug: repository.to_param,
                       data: {attributes: {encoding: 'base64',
                                           commit_message: commit_message,
                                           path: path}}}
          end
          it_behaves_like 'a failing TreesController on POST create'

          it 'shows the content error' do
            expect(response_hash['errors'].first).
              to include('source' => {'pointer' => '/data/attributes/content'})
          end
        end

        context 'because no encoding is given' do
          before do
            post :create,
              params: {repository_slug: repository.to_param,
                       data: {attributes: {content: content_encoded,
                                           commit_message: commit_message,
                                           path: path}}}
          end
          it_behaves_like 'a failing TreesController on POST create'

          it 'shows the content error' do
            expect(response_hash['errors'].first).
              to include('source' => {'pointer' => '/data/attributes/encoding'})
          end
        end

        context 'because a resource at that path already exists' do
          before do
            existing_path = git.tree(branch, '/').first.path
            post :create,
              params: {repository_slug: repository.to_param,
                       data: {attributes: {content: content_encoded,
                                           encoding: 'base64',
                                           commit_message: commit_message,
                                           path: existing_path}}}
          end
          it_behaves_like 'a failing TreesController on POST create'

          it 'shows the path error' do
            expect(response_hash['errors'].first).
              to include('source' => {'pointer' => '/data/attributes/path'})
          end
        end
      end
    end

    describe 'PATCH update' do
      let(:path) do
        git.tree(branch, git.tree(branch, '/').first.path).first.path
      end
      let(:updated_path) { generate(:filepath) }
      let(:commit_message) { generate(:commit_message) }
      let!(:content) { git.blob(branch, path).data }
      let(:content_encoded) { Base64.strict_encode64(content) }
      let(:updated_content) { 'some updated content' }

      context 'successful' do
        before do
          patch :update,
            params: {repository_slug: repository.to_param,
                     path: path,
                     data: {attributes: {content: updated_content,
                                         encoding: 'plain',
                                         commit_message: commit_message,
                                         path: updated_path}}}
        end

        it { expect(response).to have_http_status(:ok) }
        it { |example| expect([example, response]).to comply_with_api }

        it 'moves the file and ' do
          expect(git.blob(branch, updated_path).data).to eq(updated_content)
        end
      end

      context 'failing' do
        context 'because the path does not exist' do
          before do
            patch :update,
              params: {repository_slug: repository.to_param,
                       path: 'a-path-that-does-not-exist',
                       data: {attributes: {content: updated_content,
                                           encoding: 'plain',
                                           commit_message: commit_message,
                                           path: updated_path}}}
          end

          it { expect(response).to have_http_status(:not_found) }
          it { expect(response.body.strip).to be_empty }
        end

        context 'because no path and no content is given' do
          before do
            patch :update,
              params: {repository_slug: repository.to_param,
                       path: path,
                       data: {attributes: {encoding: 'plain',
                                           commit_message: commit_message}}}
          end
          it_behaves_like 'a failing TreesController on PATCH update'

          it 'shows the content error' do
            expect(response_hash['errors'].first).
              to include('source' => {'pointer' => '/data/attributes/content'})
          end
        end

        context 'because no encoding is given' do
          before do
            patch :update,
              params: {repository_slug: repository.to_param,
                       path: path,
                       data: {attributes: {content: updated_content,
                                           commit_message: commit_message,
                                           path: path}}}
          end
          it_behaves_like 'a failing TreesController on PATCH update'

          it 'shows the content error' do
            expect(response_hash['errors'].first).
              to include('source' => {'pointer' => '/data/attributes/encoding'})
          end
        end
      end
    end

    describe 'DELETE destroy' do
      let(:path) do
        git.tree(branch, git.tree(branch, '/').first.path).first.path
      end

      context 'successful' do
        before do
          delete :destroy,
            params: {repository_slug: repository.to_param, path: path}
        end

        it { expect(response).to have_http_status(:no_content) }
        it { expect(response.body.strip).to be_empty }
        it 'removes the file from the git' do
          expect(git.blob(branch, path)).to be(nil)
        end
      end
    end
  end

  context 'with a ref' do
    let(:branch_sha) { git.branch_sha(git.default_branch) }

    describe 'GET show tree' do
      before do
        get :show, params: {repository_slug: repository.to_param,
                            ref: branch,
                            path: '/'}
      end

      it_behaves_like 'a TreesController on GET show'
    end

    describe 'GET show blob' do
      before do
        subpath = git.tree(branch, '/').first.path
        path = git.tree(branch, subpath).first.path
        get :show, params: {repository_slug: repository.to_param,
                            ref: branch,
                            path: path}
      end

      it_behaves_like 'a TreesController on GET show'
    end

    describe 'GET show to non-existent path' do
      before do
        get :show, params: {repository_slug: repository.to_param,
                            ref: branch,
                            path: '/this/path/does-not-exist'}
      end

      it { expect(response).to have_http_status(:not_found) }
    end

    describe 'POST create' do
      let(:path) { generate(:filepath) }
      let(:commit_message) { generate(:commit_message) }
      let(:content) { 'some content' }
      let(:content_encoded) { Base64.strict_encode64(content) }

      context 'successful' do
        before do
          post :create,
            params: {repository_slug: repository.to_param,
                     ref: branch,
                     data: {attributes: {content: content_encoded,
                                         encoding: 'base64',
                                         commit_message: commit_message,
                                         path: path}}}
        end
        it_behaves_like 'a TreesController on POST create'
      end

      context 'failing' do
        context 'because a commit id is given instead of a branch name' do
          before do
            post :create,
              params: {repository_slug: repository.to_param,
                       ref: branch_sha,
                       data: {attributes: {content: content_encoded,
                                           encoding: 'base64',
                                           commit_message: commit_message,
                                           path: path}}}
          end
          it_behaves_like 'a failing TreesController on POST create'

          it 'shows the branch error' do
            expect(response_hash['errors'].first).
              to include('source' => {'pointer' => '/data/attributes/branch'})
          end
        end
      end
    end

    describe 'PATCH update' do
      let(:path) do
        git.tree(branch, git.tree(branch, '/').first.path).first.path
      end
      let(:updated_path) { generate(:filepath) }
      let(:commit_message) { generate(:commit_message) }
      let!(:content) { git.blob(branch, path).data }
      let(:content_encoded) { Base64.strict_encode64(content) }
      let(:updated_content) { 'some updated content' }

      context 'successful' do
        before do
          patch :update,
            params: {repository_slug: repository.to_param,
                     ref: branch,
                     path: path,
                     data: {attributes: {content: updated_content,
                                         encoding: 'plain',
                                         commit_message: commit_message,
                                         path: updated_path}}}
        end

        it { expect(response).to have_http_status(:ok) }
        it { |example| expect([example, response]).to comply_with_api }

        it 'moves the file and changes the content' do
          expect(git.blob(branch, updated_path).data).to eq(updated_content)
        end
      end

      context 'failing' do
        context 'because a commit id is given instead of a branch name' do
          before do
            post :create,
              params: {repository_slug: repository.to_param,
                       ref: branch_sha,
                       path: path,
                       data: {attributes: {content: updated_content,
                                           encoding: 'plain',
                                           commit_message: commit_message,
                                           path: updated_path}}}
          end
          it_behaves_like 'a failing TreesController on PATCH update'

          it 'shows the branch error' do
            expect(response_hash['errors'].first).
              to include('source' => {'pointer' => '/data/attributes/branch'})
          end
        end
      end
    end

    describe 'DELETE destroy' do
      let(:path) do
        git.tree(branch, git.tree(branch, '/').first.path).first.path
      end

      context 'successful' do
        before do
          delete :destroy,
            params: {repository_slug: repository.to_param,
                     ref: branch,
                     path: path}
        end

        it { expect(response).to have_http_status(:no_content) }
        it { expect(response.body.strip).to be_empty }
        it 'removes the file from the git' do
          expect(git.blob(branch, path)).to be(nil)
        end
      end

      context 'failing' do
        context 'because a commit id is given instead of a branch name' do
          before do
            delete :destroy,
              params: {repository_slug: repository.to_param,
                       ref: branch_sha,
                       path: path}
          end

          it { expect(response).to have_http_status(:unprocessable_entity) }
          it do |example|
            expect([example, response]).to comply_with_api('validation_error')
          end

          it 'shows the branch error' do
            expect(response_hash['errors'].last).
              to include('source' => {'pointer' => '/data/attributes/branch'})
          end

          it 'does not delete the file from the git' do
            expect(git.blob(branch, path)).not_to be(nil)
          end
        end
      end
    end
  end
end
