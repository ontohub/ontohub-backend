# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'a PremiseSelectionPolicy' do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:reasoner_configuration) { create(:reasoner_configuration) }

  before do
    proof_attempt =
      create(:proof_attempt, reasoner_configuration: reasoner_configuration)
    proof_attempt.repository.update(public_access: false)
  end

  context 'when current_user is a User' do
    context 'show?' do
      context 'no PremiseSelection' do
        subject { described_class.new(user, nil) }

        it 'returns false' do
          expect(subject.show?).to be(false)
        end
      end

      context 'with at least one accessible repository' do
        before do
          proof_attempt =
            create(:proof_attempt,
                   reasoner_configuration: reasoner_configuration)
          proof_attempt.repository.update(public_access: true)
        end

        context 'signed in' do
          subject do
            described_class.new(user, premise_selection)
          end

          it 'allows to show the repository' do
            expect(subject.show?).to be(true)
          end
        end

        context 'signed in as admin' do
          subject do
            described_class.new(admin, premise_selection)
          end

          it 'allows to show the repository' do
            expect(subject.show?).to be(true)
          end
        end

        context 'not signed in' do
          subject do
            described_class.new(nil, premise_selection)
          end

          it 'allows to show the repository' do
            expect(subject.show?).to be(true)
          end
        end
      end

      context 'with only inaccessible repositories' do
        context 'not signed in' do
          subject do
            described_class.new(nil, premise_selection)
          end

          it 'does not allow to show the repository' do
            expect(subject.show?).to be(false)
          end
        end

        context 'signed in as admin' do
          subject do
            described_class.new(admin, premise_selection)
          end

          it 'allows to show the repository' do
            expect(subject.show?).to be(true)
          end
        end

        context 'signed in as user without access' do
          subject do
            described_class.new(user, premise_selection)
          end

          it 'does not allow to show the repository' do
            expect(subject.show?).to be(false)
          end
        end
      end
    end
  end

  context 'when current_user is an ApiKey' do
    let(:current_user) { create(:api_key) }
    subject do
      described_class.new(current_user, premise_selection)
    end

    it 'does allow show?' do
      expect(subject.show?).to be(true)
    end
  end
end
