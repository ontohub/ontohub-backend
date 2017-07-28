# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy do
  let(:user) { create :user }
  let(:admin) { create :user, :admin }
  let(:other_user) { create :user }

  context 'show?' do
    context 'signed in' do
      subject { UserPolicy.new(user, other_user) }

      it 'allows to show the user' do
        expect(subject.show?).to be(true)
      end
    end

    context 'signed in as admin' do
      subject { UserPolicy.new(admin, other_user) }

      it 'allows to show the user' do
        expect(subject.show?).to be(true)
      end
    end

    context 'not signed in' do
      subject { UserPolicy.new(nil, other_user) }

      it 'allows to show the user' do
        expect(subject.show?).to be(true)
      end
    end
  end

  context 'show_current_user?' do
    context 'signed in' do
      subject { UserPolicy.new(user, other_user) }

      it 'allows to show the user' do
        expect(subject.show_current_user?).to be(true)
      end
    end

    context 'signed in as admin' do
      subject { UserPolicy.new(admin, other_user) }

      it 'allows to show the user' do
        expect(subject.show_current_user?).to be(true)
      end
    end

    context 'not signed in' do
      subject { UserPolicy.new(nil, other_user) }

      it 'does not allow to show the user' do
        expect(subject.show_current_user?).to be(false)
      end
    end
  end

  context 'email?' do
    context 'signed in as admin' do
      subject { UserPolicy.new(admin, other_user) }

      it 'allows to see the users email' do
        expect(subject.email?).to be(true)
      end
    end

    context 'signed in' do
      context 'own email' do
        subject { UserPolicy.new(user, user) }

        it 'allows to see my email' do
          expect(subject.email?).to be(true)
        end
      end

      context 'other users email' do
        subject { UserPolicy.new(user, other_user) }

        it 'does not allow to see the users email' do
          expect(subject.email?).to be(false)
        end
      end
    end

    context 'not signed in' do
      subject { UserPolicy.new(nil, other_user) }

      it 'does not allow to see the users email' do
        expect(subject.email?).to be(false)
      end
    end
  end
end
