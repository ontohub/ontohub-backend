# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'a ReasoningAttemptPolicy' do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let!(:public_repo) { create(:repository, public_access: true) }
  let!(:private_repo) { create(:repository, public_access: false) }

  context 'when current_user is a User' do
    context 'show?' do
      context 'no ReasoningAttempt' do
        subject { described_class.new(user, nil) }

        it 'returns false' do
          expect(subject.show?).to be(false)
        end
      end

      context 'with an accessible repository' do
        before do
          file_version.update(repository_id: public_repo.id)
        end

        context 'signed in' do
          subject { described_class.new(user, reasoning_attempt) }

          it 'allows to show the repository' do
            expect(subject.show?).to be(true)
          end
        end

        context 'signed in as admin' do
          subject { described_class.new(admin, reasoning_attempt) }

          it 'allows to show the repository' do
            expect(subject.show?).to be(true)
          end
        end

        context 'not signed in' do
          subject { described_class.new(nil, reasoning_attempt) }

          it 'allows to show the repository' do
            expect(subject.show?).to be(true)
          end
        end
      end

      context 'with only inaccessible repositories' do
        before do
          file_version.update(repository_id: private_repo.id)
        end

        context 'not signed in' do
          subject { described_class.new(nil, reasoning_attempt) }

          it 'does not allow to show the repository' do
            expect(subject.show?).to be(false)
          end
        end

        context 'signed in as admin' do
          subject { described_class.new(admin, reasoning_attempt) }

          it 'allows to show the repository' do
            expect(subject.show?).to be(true)
          end
        end

        context 'signed in as user without access' do
          subject { described_class.new(user, reasoning_attempt) }

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
        described_class.new(current_user, reasoning_attempt)
      end

      it 'does not allow show?' do
        expect(subject.show?).to be(false)
      end
    end

    context 'HetsApiKey' do
      let(:current_user) { create(:hets_api_key) }
      subject do
        described_class.new(current_user, reasoning_attempt)
      end

      it 'does allow show?' do
        expect(subject.show?).to be(true)
      end
    end
  end
end
