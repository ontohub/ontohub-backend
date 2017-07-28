# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionPolicy do
  let(:user) { create :user }
  let(:admin) { create :user, :admin }

  context 'create?' do
    context 'not signed in' do
      subject { SessionPolicy.new(nil) }

      it 'allows to sign in' do
        expect(subject.create?).to be(true)
      end
    end

    context 'signed in as user' do
      subject { SessionPolicy.new(user) }

      it 'does not allow to sign in' do
        expect(subject.create?).to be(false)
      end
    end

    context 'signed in as admin' do
      subject { SessionPolicy.new(admin) }

      it 'allows to sign in (makes no sense, but admin is god)' do
        expect(subject.create?).to be(true)
      end
    end
  end
end
