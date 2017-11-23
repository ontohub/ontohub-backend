# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SignatureMorphismPolicy do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let!(:public_repo) { create(:repository, public_access: true) }
  let!(:private_repo) { create(:repository, public_access: false) }
  let(:signature_morphism) { create(:signature_morphism) }

  context 'when current_user is a User' do
    context 'show?' do
      context 'no Signature' do
        subject { SignatureMorphismPolicy.new(user, nil) }

        it 'returns false' do
          expect(subject.show?).to be(false)
        end
      end

      context 'with at least one accessible repository' do
        before do
          document_public =
            create(:document, file_version: create(:file_version,
                                                   repository: public_repo))
          create(:oms, signature: signature_morphism.source,
                       document: document_public)

          document_private =
            create(:document, file_version: create(:file_version,
                                                   repository: private_repo))
          create(:oms, signature: signature_morphism.source,
                       document: document_private)
        end

        context 'signed in' do
          subject { SignatureMorphismPolicy.new(user, signature_morphism) }

          it 'allows to show the repository' do
            expect(subject.show?).to be(true)
          end
        end

        context 'signed in as admin' do
          subject { SignatureMorphismPolicy.new(admin, signature_morphism) }

          it 'allows to show the repository' do
            expect(subject.show?).to be(true)
          end
        end

        context 'not signed in' do
          subject { SignatureMorphismPolicy.new(nil, signature_morphism) }

          it 'allows to show the repository' do
            expect(subject.show?).to be(true)
          end
        end
      end

      context 'with only inaccessible repositories' do
        before do
          document_private =
            create(:document, file_version: create(:file_version,
                                                   repository: private_repo))
          create(:oms, signature: signature_morphism.source,
                       document: document_private)
        end

        context 'not signed in' do
          subject { SignatureMorphismPolicy.new(nil, signature_morphism) }

          it 'does not allow to show the repository' do
            expect(subject.show?).to be(false)
          end
        end

        context 'signed in as admin' do
          subject { SignatureMorphismPolicy.new(admin, signature_morphism) }

          it 'allows to show the repository' do
            expect(subject.show?).to be(true)
          end
        end

        context 'signed in as user without access' do
          subject { SignatureMorphismPolicy.new(user, signature_morphism) }

          it 'does not allow to show the repository' do
            expect(subject.show?).to be(false)
          end
        end
      end
    end
  end

  context 'when current_user is an ApiKey' do
    let(:current_user) { create(:api_key) }
    subject { SignatureMorphismPolicy.new(current_user, signature_morphism) }

    it 'does allow show?' do
      expect(subject.show?).to be(true)
    end
  end
end
