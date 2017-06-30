# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VersionPolicy do
  context 'show?' do
    context 'signed in' do
      let(:current_user) { create :user }
      subject { VersionPolicy.new(current_user) }

      it 'should show the version' do
        expect(subject.show?).to eq(true)
      end
    end

    context 'signed in as admin' do
      let(:current_user) { create :user, role: 'admin' }
      subject { VersionPolicy.new(current_user) }

      it 'should show the version' do
        expect(subject.show?).to eq(true)
      end
    end

    context 'not signed in' do
      let(:current_user) { nil }
      subject { VersionPolicy.new(current_user) }

      it 'should show the version' do
        expect(subject.show?).to eq(true)
      end
    end
  end
end
