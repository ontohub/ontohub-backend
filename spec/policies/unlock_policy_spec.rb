# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnlockPolicy do
  context 'when current_user is a User' do
    let(:user) { create :user }
    let(:admin) { create :user, :admin }

    context 'resend_unlocking_email?' do
      context 'signed in' do
        subject { UnlockPolicy.new(user) }

        it 'allows to resend the unlocking email' do
          expect(subject.resend_unlocking_email?).to be(true)
        end
      end

      context 'signed in as admin' do
        subject { UnlockPolicy.new(admin) }

        it 'allows to resend the unlocking email' do
          expect(subject.resend_unlocking_email?).to be(true)
        end
      end

      context 'not signed in' do
        subject { UnlockPolicy.new(nil) }

        it 'allows to resend the unlocking email' do
          expect(subject.resend_unlocking_email?).to be(true)
        end
      end
    end

    context 'unlock_account?' do
      context 'signed in' do
        subject { UnlockPolicy.new(user) }

        it 'allows to unlock the account' do
          expect(subject.unlock_account?).to be(true)
        end
      end

      context 'signed in as admin' do
        subject { UnlockPolicy.new(admin) }

        it 'allows to unlock the account' do
          expect(subject.unlock_account?).to be(true)
        end
      end

      context 'not signed in' do
        subject { UnlockPolicy.new(nil) }

        it 'allows to unlock the account' do
          expect(subject.unlock_account?).to be(true)
        end
      end
    end
  end

  context 'when current_user is an ApiKey' do
    context 'GitShellApiKey' do
      let(:current_user) { create(:git_shell_api_key) }
      subject do
        UnlockPolicy.new(current_user)
      end

      %i(resend_unlocking_email? unlock_account?).each do |method|
        it "does not allow #{method}" do
          expect(subject.public_send(method)).to be(false)
        end
      end
    end

    context 'HetsApiKey' do
      let(:current_user) { create(:hets_api_key) }
      subject do
        UnlockPolicy.new(current_user)
      end

      %i(resend_unlocking_email? unlock_account?).each do |method|
        it "does not allow #{method}" do
          expect(subject.public_send(method)).to be(false)
        end
      end
    end
  end
end
