# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionPolicy do
  context 'create?' do
    context 'not signed in' do
      let(:current_user) { nil }
      subject { SessionPolicy.new(current_user) }

      it 'should allow to sign in' do
        expect(subject.create?).to be(true)
      end
    end

    context 'signed in as user' do
      let(:current_user) { create :user }
      subject { SessionPolicy.new(current_user) }

      it 'should not allow to sign in' do
        expect(subject.create?).to be(false)
      end
    end

    context 'signed in as admin' do
      let(:current_user) { create :user, :admin }
      subject { SessionPolicy.new(current_user) }

      it 'should allow to sign in (makes no sense, but admin is god)' do
        expect(subject.create?).to be(true)
      end
    end
  end
end
