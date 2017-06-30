# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConfirmationPolicy do
  context 'create?' do
    context 'signed in' do
      let(:current_user) { create :user }
      subject { ConfirmationPolicy.new(current_user) }

      it 'should resend email' do
        expect(subject.create?).to be(true)
      end
    end

    context 'signed in as admin' do
      let(:current_user) { create :user, :admin }
      subject { ConfirmationPolicy.new(current_user) }

      it 'should resend email' do
        expect(subject.create?).to be(true)
      end
    end

    context 'not signed in' do
      let(:current_user) { nil }
      subject { ConfirmationPolicy.new(current_user) }

      it 'should resend email' do
        expect(subject.create?).to be(true)
      end
    end
  end

  context 'update?' do
    context 'signed in' do
      let(:current_user) { create :user }
      subject { ConfirmationPolicy.new(current_user) }

      it 'should send confirmation' do
        expect(subject.update?).to be(true)
      end
    end

    context 'signed in as admin' do
      let(:current_user) { create :user, :admin }
      subject { ConfirmationPolicy.new(current_user) }

      it 'should send confirmation' do
        expect(subject.update?).to be(true)
      end
    end

    context 'not signed in' do
      let(:current_user) { nil }
      subject { ConfirmationPolicy.new(current_user) }

      it 'should send confirmation' do
        expect(subject.update?).to be(true)
      end
    end
  end
end
