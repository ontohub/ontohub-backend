# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PasswordPolicy do
  context 'recover_password?' do
    context 'signed in' do
      let(:current_user) { create :user }
      subject { PasswordPolicy.new(current_user) }

      it 'should allow to recover the password' do
        expect(subject.recover_password?).to be(true)
      end
    end

    context 'signed in as admin' do
      let(:current_user) { create :user, :admin }
      subject { PasswordPolicy.new(current_user) }

      it 'should allow to recover the password' do
        expect(subject.recover_password?).to be(true)
      end
    end

    context 'not signed in' do
      let(:current_user) { nil }
      subject { PasswordPolicy.new(current_user) }

      it 'should allow to recover the password' do
        expect(subject.recover_password?).to be(true)
      end
    end
  end

  context 'resend_password_recovery_email?' do
    context 'signed in' do
      let(:current_user) { create :user }
      subject { PasswordPolicy.new(current_user) }

      it 'should allow to resend the password recovery email' do
        expect(subject.resend_password_recovery_email?).to be(true)
      end
    end

    context 'signed in as admin' do
      let(:current_user) { create :user, :admin }
      subject { PasswordPolicy.new(current_user) }

      it 'should allow to resend the password recovery email' do
        expect(subject.resend_password_recovery_email?).to be(true)
      end
    end

    context 'not signed in' do
      let(:current_user) { nil }
      subject { PasswordPolicy.new(current_user) }

      it 'should allow to resend the password recovery email' do
        expect(subject.resend_password_recovery_email?).to be(true)
      end
    end
  end
end
