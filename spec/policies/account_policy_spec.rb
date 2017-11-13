# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountPolicy do
  context 'when current_user is a User' do
    let(:user) { create :user }
    let(:admin) { create :user, :admin }

    context 'create?' do
      context 'not signed in' do
        subject { AccountPolicy.new(nil) }

        it 'allows to create an account' do
          expect(subject.create?).to be(true)
        end
      end

      context 'signed in as user' do
        subject { AccountPolicy.new(user) }

        it 'does not allow to create an account' do
          expect(subject.create?).to be(false)
        end
      end

      context 'signed in as admin' do
        subject { AccountPolicy.new(admin) }

        it 'allows to create an account '\
          '(makes no sense, but admin is god)' do
          expect(subject.create?).to be(true)
        end
      end
    end

    context 'update?' do
      context 'not signed in' do
        subject { AccountPolicy.new(nil) }

        it 'does not allow to update the account' do
          expect(subject.update?).to be(false)
        end
      end

      context 'signed in as user' do
        subject { AccountPolicy.new(user) }

        it 'does not allow to update the account' do
          expect(subject.update?).to be(true)
        end
      end

      context 'signed in as admin' do
        subject { AccountPolicy.new(admin) }

        it 'allows to update the account' do
          expect(subject.update?).to be(true)
        end
      end
    end

    context 'destroy?' do
      context 'not signed in' do
        subject { AccountPolicy.new(nil) }

        it 'does not allow to destroy the account' do
          expect(subject.destroy?).to be(false)
        end
      end

      context 'signed in as user' do
        subject { AccountPolicy.new(user) }

        it 'does not allow to destroy the account' do
          expect(subject.destroy?).to be(true)
        end
      end

      context 'signed in as admin' do
        subject { AccountPolicy.new(admin) }

        it 'allows to destroy the account' do
          expect(subject.destroy?).to be(true)
        end
      end
    end
  end

  context 'when current_user is an ApiKey' do
    let(:current_user) { create(:api_key) }
    subject { AccountPolicy.new(current_user) }

    %i(create? update? destroy?).each do |method|
      context method.to_s do
        it 'does not allow the action' do
          expect(subject.public_send(method)).to be(false)
        end
      end
    end
  end
end
