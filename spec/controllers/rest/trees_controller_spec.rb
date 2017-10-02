# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples('trees#show file') do
  before { get :show, params: params }

  it { expect(response).to have_http_status(:ok) }
  it { |example| expect([example, response]).to comply_with_rest_api }

  it 'is a file' do
    expect(response_data.dig('repository', 'commit', 'file')).
      not_to be(nil)
  end

  it 'is not a directory' do
    expect(response_data.dig('repository', 'commit', 'directory')).
      to be(nil)
  end
end

RSpec.shared_examples('trees#show directory') do
  before { get :show, params: params }

  it { expect(response).to have_http_status(:ok) }
  it { |example| expect([example, response]).to comply_with_rest_api }

  it 'is not a file' do
    expect(response_data.dig('repository', 'commit', 'file')).
      to be(nil)
  end

  it 'is a directory' do
    expect(response_data.dig('repository', 'commit', 'directory')).
      not_to be(nil)
  end
end

RSpec.shared_examples('trees#show nothing') do
  before { get :show, params: params }

  it { expect(response).to have_http_status(:ok) }
  it { |example| expect([example, response]).to comply_with_rest_api }

  it 'is not a file' do
    expect(response_data.dig('repository', 'commit', 'file')).
      to be(nil)
  end

  it 'is not a directory' do
    expect(response_data.dig('repository', 'commit', 'directory')).
      to be(nil)
  end
end

RSpec.describe Rest::TreesController do
  describe 'action: show' do
    let(:load_bytes) { 5 }
    before do
      stub_const('Gitlab::Git::Blob::MAX_DATA_DISPLAY_SIZE', load_bytes)
    end

    let(:repository) { create(:repository_compound) }
    let(:file_content) { generate(:content) }
    let!(:file) do
      path = generate(:filepath)
      create(:additional_file, repository: repository,
                               path: path,
                               content: file_content)
      path
    end
    let(:directory) { File.dirname(file) }

    let(:revision) { nil }
    let(:load_all_data) { nil }

    let(:params) do
      p = {organizational_unit_id: repository.slug.split('/', 2).first,
           repository_id: repository.slug.split('/', 2).last,
           revision: revision,
           loadAllData: load_all_data,
           path: path}
      p.delete(:revision) if revision.nil?
      p.delete(:loadAllData) if load_all_data.nil?
      p
    end

    context 'json' do
      context 'on a file' do
        let(:path) { file }
        it_behaves_like 'trees#show file'

        context 'with a revision' do
          let(:revision) { repository.git.default_branch }
          it_behaves_like 'trees#show file'
        end

        context 'loadAllData' do
          context 'false' do
            it_behaves_like 'trees#show file'

            it 'loads only the first bytes of the content' do
              get :show, params: params
              expect(response_data.
                     dig('repository', 'commit', 'file', 'content')).
                to eq(file_content[0..load_bytes - 1])
            end

            it 'does not load the full content' do
              get :show, params: params
              expect(response_data.
                     dig('repository', 'commit', 'file', 'content')).
                not_to eq(file_content)
            end
          end

          context 'true' do
            let(:load_all_data) { true }

            it_behaves_like 'trees#show file'

            it 'loads the full content' do
              get :show, params: params
              expect(response_data.
                       dig('repository', 'commit', 'file', 'content')).
                to eq(file_content)
            end
          end
        end
      end

      context 'on a directory' do
        let(:path) { directory }
        it_behaves_like 'trees#show directory'

        context 'with a revision' do
          let(:revision) { repository.git.default_branch }
          it_behaves_like 'trees#show directory'
        end
      end

      context 'on nothing' do
        let(:path) { "bad-#{file}" }
        it_behaves_like 'trees#show nothing'

        context 'with a revision' do
          let(:revision) { repository.git.default_branch }
          it_behaves_like 'trees#show nothing'
        end
      end
    end

    context 'plain' do
      before do
        request.headers['Accept'] = 'text/plain'
        get :show, params: params
      end

      context 'on a file' do
        let(:path) { file }

        context 'load_all_data false' do
          it { expect(response).to have_http_status(:ok) }
          it 'responds with the full plain text version' do
            expect(response.body).to eq(file_content)
          end
        end

        context 'load_all_data true' do
          let(:load_all_data) { true }

          it { expect(response).to have_http_status(:ok) }
          it 'responds with the full plain text version' do
            expect(response.body).to eq(file_content)
          end
        end
      end

      context 'on a directory' do
        let(:path) { directory }

        it { expect(response).to have_http_status(:not_found) }
        it 'has an empty body' do
          expect(response.body).to be_blank
        end
      end

      context 'on nothing' do
        let(:path) { "bad-#{file}" }

        it { expect(response).to have_http_status(:not_found) }
        it 'has an empty body' do
          expect(response.body).to be_blank
        end
      end
    end
  end
end
