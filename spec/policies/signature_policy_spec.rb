# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SignaturePolicy do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let!(:public_repo) { create(:repository, public_access: true) }
  let!(:private_repo) { create(:repository, public_access: false) }
  let(:signature) { create(:signature) }

  context 'when current_user is a User' do
    context 'show?' do
      context 'no Signature' do
        subject { SignaturePolicy.new(user, nil) }

        it 'returns false' do
          expect(subject.show?).to be(false)
        end
      end

      context 'with at least one accessible repository' do
        before do
          document_public =
            create(:document, file_version: create(:file_version,
                                                   repository: public_repo))
          create(:oms, signature: signature, document: document_public)

          document_private =
            create(:document, file_version: create(:file_version,
                                                   repository: private_repo))
          create(:oms, signature: signature, document: document_private)
        end

        context 'signed in' do
          subject { SignaturePolicy.new(user, signature) }

          it 'allows to show the repository' do
            expect(subject.show?).to be(true)
          end
        end

        context 'signed in as admin' do
          subject { SignaturePolicy.new(admin, signature) }

          it 'allows to show the repository' do
            expect(subject.show?).to be(true)
          end
        end

        context 'not signed in' do
          subject { SignaturePolicy.new(nil, signature) }

          it 'allows to show the repository' do
            expect(subject.show?).to be(true)
          end
        end
      end

      context 'with only inaccessible repositories' do
        before do
          document =
            create(:document, file_version: create(:file_version,
                                                   repository: private_repo))
          create(:oms, signature: signature, document: document)
        end

        context 'not signed in' do
          subject { SignaturePolicy.new(nil, signature) }

          it 'does not allow to show the repository' do
            expect(subject.show?).to be(false)
          end
        end

        context 'signed in as admin' do
          subject { SignaturePolicy.new(admin, signature) }

          it 'allows to show the repository' do
            expect(subject.show?).to be(true)
          end
        end

        context 'signed in as user without access' do
          subject { SignaturePolicy.new(user, signature) }

          it 'does not allow to show the repository' do
            expect(subject.show?).to be(false)
          end
        end
      end
    end
  end

  context 'when current_user is an ApiKey' do
    context 'GitShellApiKey' do
      let(:current_user) { create(:git_shell_api_key) }
      subject do
        SignaturePolicy.new(current_user, signature)
      end

      it 'does not allow show?' do
        expect(subject.show?).to be(false)
      end
    end

    context 'HetsApiKey' do
      let(:current_user) { create(:hets_api_key) }
      subject do
        SignaturePolicy.new(current_user, signature)
      end

      it 'does not allow show?' do
        expect(subject.show?).to be(false)
      end
    end
  end
end
