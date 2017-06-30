# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy do
  context 'show?' do
    let(:user) { create :user }

    context 'signed in' do
      let(:current_user) { create :user }
      subject { UserPolicy.new(current_user, user) }

      it 'should show the user' do
        expect(subject.show?).to be(true)
      end
    end

    context 'signed in as admin' do
      let(:current_user) { create :user, role: 'admin' }
      subject { UserPolicy.new(current_user, user) }

      it 'should show the user' do
        expect(subject.show?).to be(true)
      end
    end

    context 'not signed in' do
      let(:current_user) { nil }
      subject { UserPolicy.new(current_user, user) }

      it 'should show the user' do
        expect(subject.show?).to be(true)
      end
    end
  end

context 'show_current_user?' do
    let(:user) { create :user }

    context 'signed in' do
      let(:current_user) { create :user }
      subject { UserPolicy.new(current_user, user) }

      it 'should show the user' do
        expect(subject.show_current_user?).to be(true)
      end
    end

    context 'signed in as admin' do
      let(:current_user) { create :user, role: 'admin' }
      subject { UserPolicy.new(current_user, user) }

      it 'should show the user' do
        expect(subject.show_current_user?).to be(true)
      end
    end

    context 'not signed in' do
      let(:current_user) { nil }
      subject { UserPolicy.new(current_user, user) }

      it 'shouldnt show the user' do
        expect(subject.show_current_user?).to be(false)
      end
    end
  end

end
