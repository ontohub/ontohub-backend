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

RSpec.shared_examples 'a failing TreesController on PATCH multiaction' do
  it { expect(response).to have_http_status(:unprocessable_entity) }
  it do |example|
    expect([example, response]).to comply_with_api('validation_error')
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
        context 'with a content change, with renaming' do
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

          it 'moves the file and changes its content' do
            expect(git.blob(branch, updated_path).data).to eq(updated_content)
          end
        end

        context 'with a content change, without renaming' do
          before do
            patch :update,
              params: {repository_slug: repository.to_param,
                       path: path,
                       data: {attributes: {content: updated_content,
                                           encoding: 'plain',
                                           commit_message: commit_message}}}
          end

          it { expect(response).to have_http_status(:ok) }
          it { |example| expect([example, response]).to comply_with_api }

          it 'changes the file content' do
            expect(git.blob(branch, path).data).to eq(updated_content)
          end
        end

        context 'without a content change, with renaming' do
          before do
            patch :update,
              params: {repository_slug: repository.to_param,
                       path: path,
                       data: {attributes: {commit_message: commit_message,
                                           path: updated_path}}}
          end

          it { expect(response).to have_http_status(:ok) }
          it { |example| expect([example, response]).to comply_with_api }

          it 'only moves the file' do
            expect(git.blob(branch, updated_path).data).to eq(content)
          end
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

          it 'shows the encoding error' do
            expect(validation_error_at?('encoding')).to be(true)
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

  context 'PATCH multiaction' do
    let(:num_setup_files) { 6 }
    let!(:file_range) { (0..num_setup_files - 1) }
    let!(:old_files) { file_range.map { generate(:filepath) } }
    let!(:new_files) { file_range.map { generate(:filepath) } }
    let!(:old_contents) { file_range.map { generate(:content) } }
    let!(:new_contents) { file_range.map { generate(:content) } }
    let!(:setup_commit) do
      info = create(:git_commit_info, branch: branch)
      info.delete(:file)
      info[:files] = []
      file_range.each do |i|
        info[:files] << {path: old_files[i],
                         content: old_contents[i],
                         action: :create}
      end
      git.commit_multichange(info)
    end
    let(:files) do
      [{path: new_files[0],
        content: new_contents[0],
        encoding: 'plain',
        action: 'create'},

       {path: new_files[1],
        previous_path: old_files[1],
        action: 'rename'},

       {path: old_files[2],
        content: new_contents[2],
        encoding: 'plain',
        action: 'update'},

       {path: new_files[3],
        content: new_contents[3],
        encoding: 'plain',
        previous_path: old_files[3],
        action: 'update'},

       {path: old_files[4],
        action: 'remove'},

       {path: new_files[5],
        action: 'mkdir'}]
    end

    context 'successful' do
      before do
        commit_message = generate(:commit_message)
        patch :multiaction,
          params: {repository_slug: repository.to_param,
                   ref: branch,
                   data: {attributes: {files: files,
                                       commit_message: commit_message}}}
      end

      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_api }

      it 'performs the create action' do
        expect(git.blob(branch, new_files[0]).data).to eq(new_contents[0])
      end

      it 'performs the rename action: the new filename exists' do
        expect(git.blob(branch, new_files[1]).data).to eq(old_contents[1])
      end

      it 'performs the rename action: the old filename does not exist' do
        expect(git.blob(branch, old_files[1])).to be_nil
      end

      it 'performs the non-renaming update action: new content correct' do
        expect(git.blob(branch, old_files[2]).data).to eq(new_contents[2])
      end

      it 'performs the non-renaming update action: old content not there' do
        expect(git.blob(branch, old_files[2]).data).not_to eq(old_contents[2])
      end

      it 'performs the renaming update action: new filename and content' do
        expect(git.blob(branch, new_files[3]).data).to eq(new_contents[3])
      end

      it 'performs the renaming update action: the old content is gone' do
        expect(git.blob(branch, new_files[3]).data).not_to eq(old_contents[3])
      end

      it 'performs the renaming update action: '\
        'the old filename does not exist' do
        expect(git.blob(branch, old_files[3])).to be_nil
      end

      it 'performs the removing action' do
        expect(git.blob(branch, old_files[4])).to be_nil
      end

      it 'performs the mkdir action: no blob exists at path' do
        expect(git.blob(branch, new_files[5])).to be_nil
      end

      it 'performs the mkdir action: .gitkeep exists under path' do
        expect(git.tree(branch, new_files[5]).first.path).
          to end_with('/.gitkeep')
      end

      it 'only adds one log entry' do
        expect(git.log(ref: "#{branch}~").first.id).to eq(setup_commit)
      end
    end

    context 'failing' do
      context 'by validation error' do
        let(:files) do
          [{path: old_files[0],
            content: new_contents[0],
            encoding: 'plain',
            action: 'create'}]
        end

        before do
          commit_message = generate(:commit_message)
          patch :multiaction,
            params: {repository_slug: repository.to_param,
                     ref: branch,
                     data: {attributes: {files: files,
                                         commit_message: commit_message}}}
        end

        it_behaves_like 'a failing TreesController on PATCH multiaction'
        it 'has the correct validation error' do
          expect(validation_errors_at('files/0/path')).
            to include(/path already exists/)
        end
      end
    end
  end
end
