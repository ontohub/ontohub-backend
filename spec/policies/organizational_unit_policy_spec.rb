# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationalUnitPolicy do
  context 'when current_user is a User' do
    let(:user) { create :user }
    let(:admin) { create :user, :admin }

    context 'show?' do
      context 'signed in' do
        subject { OrganizationalUnitPolicy.new(user) }

        it 'allows to show the organizational unit' do
          expect(subject.show?).to be(true)
        end
      end

      context 'signed in as admin' do
        subject { OrganizationalUnitPolicy.new(admin) }

        it 'allows to show the organizational unit' do
          expect(subject.show?).to be(true)
        end
      end

      context 'not signed in' do
        subject { OrganizationalUnitPolicy.new(nil) }

        it 'allows to show the organizational unit' do
          expect(subject.show?).to be(true)
        end
      end
    end
  end

  context 'when current_user is an ApiKey' do
    let(:current_user) { create(:api_key) }
    subject { OrganizationalUnitPolicy.new(current_user) }

    it 'does allow show?' do
      expect(subject.show?).to be(true)
    end
  end
end
