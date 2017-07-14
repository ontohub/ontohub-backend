# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationPolicy do
  context 'show?' do
    context 'signed in' do
      let(:current_user) { create :user }
      subject { OrganizationPolicy.new(current_user) }

      it 'should allow to show the organization' do
        expect(subject.show?).to be(true)
      end
    end

    context 'signed in as admin' do
      let(:current_user) { create :user, :admin }
      subject { OrganizationPolicy.new(current_user) }

      it 'should allow to show the organization' do
        expect(subject.show?).to be(true)
      end
    end

    context 'not signed in' do
      let(:current_user) { nil }
      subject { OrganizationPolicy.new(current_user) }

      it 'should allow to show the organization' do
        expect(subject.show?).to be(true)
      end
    end
  end
end
