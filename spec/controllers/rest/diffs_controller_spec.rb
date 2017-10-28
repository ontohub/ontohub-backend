# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rest::DiffsController do
  let(:repository) { create :repository_compound, :not_empty, commit_count: 2 }
  let(:user) { repository.owner }
  let!(:revision) { repository.git.default_branch }
  let!(:new_files) { repository.git.ls_files(revision) }
  let!(:old_files) { repository.git.ls_files("#{revision}~1") }
  let!(:last_changed_files) { new_files - old_files }

  describe 'action: single_commit' do
    before do
      get :single_commit,
        params: {organizational_unit_id: user.to_param,
                 repository_id: repository.to_param.sub(%r{\A[^/]*/}, ''),
                 revision: revision}
    end

    context 'successful' do
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
      it 'contains a diff' do
        expect(response_data['repository']['commit']['diff']).
          to include(include('newPath' => last_changed_files.first))
      end
    end

    context 'unsuccessful' do
      context 'inexistant revision' do
        let(:revision) { '0' * 40 }

        it { expect(response).to have_http_status(:ok) }
        it { |example| expect([example, response]).to comply_with_rest_api }
        it 'contains no commit' do
          expect(response_data['repository']['commit']).to be(nil)
        end
      end
    end
  end

  describe 'action: commit_range' do
    let!(:from) { "#{revision}~1" }
    let!(:to) { revision }
    let(:paths) { last_changed_files }

    before do
      get :commit_range,
        params: {organizational_unit_id: user.to_param,
                 repository_id: repository.to_param.sub(%r{\A[^/]*/}, ''),
                 from: from,
                 to: to,
                 paths: paths}
    end

    context 'successful' do
      shared_examples 'a successful response' do
        it { expect(response).to have_http_status(:ok) }
        it { |example| expect([example, response]).to comply_with_rest_api }
        it 'contains a diff' do
          expect(response_data['repository']['diff']).
            to include(include('newPath' => last_changed_files.first))
        end
      end

      context 'without paths' do
        let(:paths) { nil }
        it_behaves_like 'a successful response'
      end

      context 'with a single path' do
        let(:paths) { last_changed_files.first }
        it_behaves_like 'a successful response'
      end

      context 'with an array of paths' do
        it_behaves_like 'a successful response'
      end
    end

    context 'unsuccessful' do
      shared_examples 'a response with an error' do |error_location|
        it { expect(response).to have_http_status(:ok) }

        it { |example| expect([example, response]).to comply_with_rest_api }

        it 'contains no repository data' do
          expect(response_data['repository']).to be(nil)
        end

        it "contains an error at #{error_location}" do
          error_matcher = /#{error_location}.*revspec.*not found/
          expect(response_hash['errors']).
            to include(include('message' => match(error_matcher)))
        end
      end

      context 'inexistant "from" revision' do
        let(:from) { '0' * 40 }
        it_behaves_like 'a response with an error', 'from'
      end

      context 'inexistant "to" revision' do
        let(:to) { '0' * 40 }
        it_behaves_like 'a response with an error', 'to'
      end
    end
  end
end
