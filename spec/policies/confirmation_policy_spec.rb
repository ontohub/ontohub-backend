# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConfirmationPolicy do
  let(:user) { create :user }
  let(:admin) { create :user, :admin }

  context 'create?' do
    context 'signed in' do
      subject { ConfirmationPolicy.new(user) }

      it 'allows to resend email' do
        expect(subject.create?).to be(true)
      end
    end

    context 'signed in as admin' do
      subject { ConfirmationPolicy.new(admin) }

      it 'allows to resend email' do
        expect(subject.create?).to be(true)
      end
    end

    context 'not signed in' do
      subject { ConfirmationPolicy.new(nil) }

      it 'allows to resend email' do
        expect(subject.create?).to be(true)
      end
    end
  end

  context 'update?' do
    context 'signed in' do
      subject { ConfirmationPolicy.new(user) }

      it 'allows to perform the confirmation' do
        expect(subject.update?).to be(true)
      end
    end

    context 'signed in as admin' do
      subject { ConfirmationPolicy.new(admin) }

      it 'allows to perform the confirmation' do
        expect(subject.update?).to be(true)
      end
    end

    context 'not signed in' do
      subject { ConfirmationPolicy.new(nil) }

      it 'allows to perform the confirmation' do
        expect(subject.update?).to be(true)
      end
    end
  end
end
