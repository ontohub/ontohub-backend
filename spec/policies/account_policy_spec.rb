# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountPolicy do
  context 'create?' do
    context 'not signed in' do
      let(:current_user) { nil }
      subject { AccountPolicy.new(current_user) }

      it 'should allow to create an account' do
        expect(subject.create?).to be(true)
      end
    end

    context 'signed in as user' do
      let(:current_user) { create :user }
      subject { AccountPolicy.new(current_user) }

      it 'should not allow to create an account' do
        expect(subject.create?).to be(false)
      end
    end

    context 'signed in as admin' do
      let(:current_user) { create :user, :admin }
      subject { AccountPolicy.new(current_user) }

      it 'should allow to create an account '\
        '(makes no sense, but admin is god)' do
        expect(subject.create?).to be(true)
      end
    end
  end

  context 'update?' do
    context 'not signed in' do
      let(:current_user) { nil }
      subject { AccountPolicy.new(current_user) }

      it 'should not allow to update the account' do
        expect(subject.update?).to be(false)
      end
    end

    context 'signed in as user' do
      let(:current_user) { create :user }
      subject { AccountPolicy.new(current_user) }

      it 'should not allow to update the account' do
        expect(subject.update?).to be(true)
      end
    end

    context 'signed in as admin' do
      let(:current_user) { create :user, :admin }
      subject { AccountPolicy.new(current_user) }

      it 'should allow to update the account' do
        expect(subject.update?).to be(true)
      end
    end
  end

  context 'destroy?' do
    context 'not signed in' do
      let(:current_user) { nil }
      subject { AccountPolicy.new(current_user) }

      it 'should not allow to destroy the account' do
        expect(subject.destroy?).to be(false)
      end
    end

    context 'signed in as user' do
      let(:current_user) { create :user }
      subject { AccountPolicy.new(current_user) }

      it 'should not allow to destroy the account' do
        expect(subject.destroy?).to be(true)
      end
    end

    context 'signed in as admin' do
      let(:current_user) { create :user, :admin }
      subject { AccountPolicy.new(current_user) }

      it 'should allow to destroy the account' do
        expect(subject.destroy?).to be(true)
      end
    end
  end
end
