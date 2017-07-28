# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VersionPolicy do
  let(:user) { create :user }
  let(:admin) { create :user, :admin }

  context 'show?' do
    context 'signed in' do
      subject { VersionPolicy.new(user) }

      it 'allows to show the version' do
        expect(subject.show?).to be(true)
      end
    end

    context 'signed in as admin' do
      subject { VersionPolicy.new(admin) }

      it 'allows to show the version' do
        expect(subject.show?).to be(true)
      end
    end

    context 'not signed in' do
      subject { VersionPolicy.new(nil) }

      it 'allows to show the version' do
        expect(subject.show?).to be(true)
      end
    end
  end
end
