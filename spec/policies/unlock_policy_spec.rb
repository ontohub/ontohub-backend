# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnlockPolicy do
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
