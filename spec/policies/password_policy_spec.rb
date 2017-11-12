# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PasswordPolicy do
  context 'when current_user is a User' do
    let(:user) { create :user }
    let(:admin) { create :user, :admin }

    context 'recover_password?' do
      context 'signed in' do
        subject { PasswordPolicy.new(user) }

        it 'allows to recover the password' do
          expect(subject.recover_password?).to be(true)
        end
      end

      context 'signed in as admin' do
        subject { PasswordPolicy.new(admin) }

        it 'allows to recover the password' do
          expect(subject.recover_password?).to be(true)
        end
      end

      context 'not signed in' do
        subject { PasswordPolicy.new(nil) }

        it 'allows to recover the password' do
          expect(subject.recover_password?).to be(true)
        end
      end
    end

    context 'resend_password_recovery_email?' do
      context 'signed in' do
        subject { PasswordPolicy.new(user) }

        it 'allows to resend the password recovery email' do
          expect(subject.resend_password_recovery_email?).to be(true)
        end
      end

      context 'signed in as admin' do
        subject { PasswordPolicy.new(admin) }

        it 'allows to resend the password recovery email' do
          expect(subject.resend_password_recovery_email?).to be(true)
        end
      end

      context 'not signed in' do
        subject { PasswordPolicy.new(nil) }

        it 'allows to resend the password recovery email' do
          expect(subject.resend_password_recovery_email?).to be(true)
        end
      end
    end
  end

  context 'when current_user is an ApiKey' do
    let(:current_user) { create(:api_key) }
    subject { PasswordPolicy.new(current_user) }

    %i(recover_password? resend_password_recovery_email?).each do |method|
      it "does not allow #{method}" do
        expect(subject.public_send(method)).to be(false)
      end
    end
  end
end
