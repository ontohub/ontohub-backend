# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'a REST DocumentsController' do
  describe 'action: show' do
    let(:repository) { create(:repository_compound) }
    let(:file_content) { generate(:content) }
    let(:file_path) { generate(:filepath) }
    let(:commit_sha) do
      create(:additional_file, repository: repository,
                               path: file_path,
                               content: file_content)
    end
    let(:file_version) do
      FileVersion.find(commit_sha: commit_sha,
                       path: file_path,
                       repository_id: repository.id)
    end
    let(:document) { create(document_factory, file_version: file_version) }
    let(:loc_id) { document.loc_id }

    let!(:link_source) { create(:document_link, source: document) }
    let!(:link_target) { create(:document_link, target: document) }

    let(:params) do
      {organizational_unit_id: repository.slug.split('/', 2).first,
       repository_id: repository.slug.split('/', 2).last,
       document_loc_id: loc_id}
    end

    context 'json' do
      before { get :show, params: params }

      context 'on a document' do
        it { expect(response).to have_http_status(:ok) }
        it { |example| expect([example, response]).to comply_with_rest_api }

        it 'is the document' do
          expect(response_data.dig('repository', 'commit', 'document')).
            to include('__typename' => document.class.to_s,
                       'documentLinks' =>
                         include(include('source' =>
                                           include('locId' => loc_id),
                                         'target' =>
                                           include('locId' =>
                                                     link_source.target.
                                                       loc_id)),
                                 include('source' =>
                                           include('locId' =>
                                                   link_target.source.
                                                     loc_id),
                                         'target' =>
                                           include('locId' => loc_id))),
                       'locId' => document.loc_id)
        end
      end

      context 'on nothing' do
        let(:loc_id) { "bad-#{document.loc_id}" }

        it 'is a document' do
          expect(response_data.dig('repository', 'commit', 'document')).
            to be(nil)
        end
      end
    end

    context 'plain' do
      before do
        request.headers['Accept'] = 'text/plain'
        get :show, params: params
      end

      context 'on a document' do
        it { expect(response).to have_http_status(:ok) }
        it 'responds with the full plain text version' do
          expect(response.body).to eq(file_content)
        end
      end

      context 'on nothing' do
        let(:loc_id) { "bad-#{document.loc_id}" }

        it { expect(response).to have_http_status(:not_found) }
        it 'has an empty body' do
          expect(response.body).to be_blank
        end
      end
    end
  end
end

RSpec.describe Rest::DocumentsController do
  context 'Library' do
    let(:document_factory) { :library }
    it_behaves_like 'a REST DocumentsController'
  end

  context 'NativeDocument' do
    let(:document_factory) { :native_document }
    it_behaves_like 'a REST DocumentsController'
  end
end
