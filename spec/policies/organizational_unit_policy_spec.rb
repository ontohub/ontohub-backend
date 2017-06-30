# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationalUnitPolicy do
  context 'show?' do
    context 'signed in' do
      let(:current_user) { create :user }
      subject { OrganizationalUnitPolicy.new(current_user) }

      it 'should allow to show the organizational unit' do
        expect(subject.show?).to be(true)
      end
    end

    context 'signed in as admin' do
      let(:current_user) { create :user, :admin }
      subject { OrganizationalUnitPolicy.new(current_user) }

      it 'should allow to show the organizational unit' do
        expect(subject.show?).to be(true)
      end
    end

    context 'not signed in' do
      let(:current_user) { nil }
      subject { OrganizationalUnitPolicy.new(current_user) }

      it 'should allow to show the organizational unit' do
        expect(subject.show?).to be(true)
      end
    end
  end
end
