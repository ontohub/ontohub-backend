# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationPolicy do
  let(:user) { create :user }
  let(:admin) { create :user, :admin }
  let(:organization) { create :organization }

  context 'show?' do
    context 'signed in' do
      subject { OrganizationPolicy.new(user, organization) }

      it 'allows to show the organization' do
        expect(subject.show?).to be(true)
      end
    end

    context 'signed in as admin' do
      subject { OrganizationPolicy.new(admin, organization) }

      it 'allows to show the organization' do
        expect(subject.show?).to be(true)
      end
    end

    context 'not signed in' do
      subject { OrganizationPolicy.new(nil, organization) }

      it 'allows to show the organization' do
        expect(subject.show?).to be(true)
      end
    end
  end

  context 'update?' do
    context 'by membership' do
      subject { OrganizationPolicy.new(user, organization) }

      %w(write read).each do |role|
        it "with role #{role} does not allow to update the organization" do
          organization.add_member(user, role)
          expect(subject.update?).to be(false)
        end
      end

      it 'with role admin does not allow to update the organization' do
        organization.add_member(user, 'admin')
        expect(subject.update?).to be(true)
      end
    end

    context 'with role admin' do
      subject { OrganizationPolicy.new(admin, organization) }

      it 'allows to update the organization' do
        expect(subject.update?).to be(true)
      end
    end

    context 'with role user' do
      subject { OrganizationPolicy.new(user, organization) }

      it 'allows to update the organization' do
        expect(subject.update?).to be(false)
      end
    end
  end

  context 'destroy?' do
    context 'by membership' do
      subject { OrganizationPolicy.new(user, organization) }

      %w(write read).each do |role|
        it "with role #{role} does not allow to destroy the organization" do
          organization.add_member(user, role)
          expect(subject.destroy?).to be(false)
        end
      end

      it 'with role admin does not allow to destroy the organization' do
        organization.add_member(user, 'admin')
        expect(subject.destroy?).to be(true)
      end
    end

    context 'with role admin' do
      subject { OrganizationPolicy.new(admin, organization) }

      it 'allows to destroy the organization' do
        expect(subject.destroy?).to be(true)
      end
    end

    context 'with role user' do
      subject { OrganizationPolicy.new(user, organization) }

      it 'allows to destroy the organization' do
        expect(subject.destroy?).to be(false)
      end
    end
  end
end
