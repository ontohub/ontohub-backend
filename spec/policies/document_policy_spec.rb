# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentPolicy do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:public_repo) { create(:repository, public_access: true) }
  let(:private_repo) { create(:repository, public_access: false) }
  let(:other_private_repo) { create(:repository, public_access: false) }
  let!(:document_in_public_repository) do
    create(:document, file_version: create(:file_version,
                                           repository: public_repo))
  end
  let!(:document_in_accessible_private_repository) do
    create(:document, file_version: create(:file_version,
                                           repository: private_repo))
  end
  let!(:document_in_inaccessible_private_repository) do
    create(:document, file_version: create(:file_version,
                                           repository: other_private_repo))
  end

  before do
    private_repo.add_member(user, :read)
  end

  let(:public_documents) { [document_in_public_repository] }
  let(:user_documents) do
    [document_in_public_repository, document_in_accessible_private_repository]
  end
  let(:admin_documents) do
    [document_in_public_repository,
     document_in_accessible_private_repository,
     document_in_inaccessible_private_repository]
  end

  context 'when current_user is a User' do
    describe DocumentPolicy::Scope do
      subject { DocumentPolicy::Scope.new(current_user, scope) }
      let(:scope) { Document.dataset }

      context 'signed in as admin' do
        let(:current_user) { admin }

        it 'returns all documents' do
          expect(subject.resolve.to_a).to match_array(admin_documents)
        end
      end

      context 'signed in as normal user' do
        let(:current_user) { user }

        it 'returns public documents and ones with explicit access' do
          expect(subject.resolve.to_a).to match_array(user_documents)
        end
      end

      context 'not signed in' do
        let(:current_user) { nil }

        it 'returns only public documents' do
          expect(subject.resolve.to_a).to match_array(public_documents)
        end
      end
    end
  end

  context 'when current_user is an ApiKey' do
    context 'GitShellApiKey' do
      let(:current_user) { create(:git_shell_api_key) }
      describe DocumentPolicy::Scope do
        subject { DocumentPolicy::Scope.new(current_user, scope) }
        let(:scope) { Document.dataset }

        it 'returns no documents' do
          expect(subject.resolve.to_a).to be_empty
        end
      end
    end

    context 'HetsApiKey' do
      let(:current_user) { create(:hets_api_key) }
      describe DocumentPolicy::Scope do
        subject { DocumentPolicy::Scope.new(current_user, scope) }
        let(:scope) { Document.dataset }

        it 'returns all documents' do
          expect(subject.resolve.to_a).to match_array(admin_documents)
        end
      end
    end
  end
end
