# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnlockPolicy do
  context 'resend_unlocking_email?' do
    context 'signed in' do
      let(:current_user) { create :user }
      subject { UnlockPolicy.new(current_user) }

      it 'should allow to resend the unlocking email' do
        expect(subject.resend_unlocking_email?).to be(true)
      end
    end

    context 'signed in as admin' do
      let(:current_user) { create :user, :admin }
      subject { UnlockPolicy.new(current_user) }

      it 'should allow to resend the unlocking email' do
        expect(subject.resend_unlocking_email?).to be(true)
      end
    end

    context 'not signed in' do
      let(:current_user) { nil }
      subject { UnlockPolicy.new(current_user) }

      it 'should allow to resend the unlocking email' do
        expect(subject.resend_unlocking_email?).to be(true)
      end
    end
  end

  context 'unlock_account?' do
    context 'signed in' do
      let(:current_user) { create :user }
      subject { UnlockPolicy.new(current_user) }

      it 'should allow to unlock the account' do
        expect(subject.unlock_account?).to be(true)
      end
    end

    context 'signed in as admin' do
      let(:current_user) { create :user, :admin }
      subject { UnlockPolicy.new(current_user) }

      it 'should allow to unlock the account' do
        expect(subject.unlock_account?).to be(true)
      end
    end

    context 'not signed in' do
      let(:current_user) { nil }
      subject { UnlockPolicy.new(current_user) }

      it 'should allow to unlock the account' do
        expect(subject.unlock_account?).to be(true)
      end
    end
  end
end
