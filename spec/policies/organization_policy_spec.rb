# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationPolicy do
  context 'show?' do
    context 'signed in' do
      let(:current_user) { create :user }
      let(:organization) { create :organization }
      subject { OrganizationPolicy.new(current_user, organization) }

      it 'should allow to show the organization' do
        expect(subject.show?).to be(true)
      end
    end

    context 'signed in as admin' do
      let(:current_user) { create :user, :admin }
      let(:organization) { create :organization }
      subject { OrganizationPolicy.new(current_user, organization) }

      it 'should allow to show the organization' do
        expect(subject.show?).to be(true)
      end
    end

    context 'not signed in' do
      let(:current_user) { nil }
      let(:organization) { create :organization }
      subject { OrganizationPolicy.new(current_user, organization) }

      it 'should allow to show the organization' do
        expect(subject.show?).to be(true)
      end
    end
  end

  context 'update?' do
    context 'by membership' do
      let(:current_user) { create :user }
      let(:organization) { create :organization }
      subject { OrganizationPolicy.new(current_user, organization) }

      %w(write read).each do |role|
        it "with role #{role} should not allow to update the organization" do
          organization.add_member(current_user, role)
          expect(subject.update?).to be(false)
        end
      end

      it 'with role admin should not allow to update the organization' do
        organization.add_member(current_user, 'admin')
        expect(subject.update?).to be(true)
      end
    end

    context 'with role admin' do
      let(:current_user) { create :user, role: 'admin' }
      let(:organization) { create :organization }
      subject { OrganizationPolicy.new(current_user, organization) }

      it 'should allow to update the organization' do
        expect(subject.update?).to be(true)
      end
    end

    context 'with role user' do
      let(:current_user) { create :user, role: 'user' }
      let(:organization) { create :organization }
      subject { OrganizationPolicy.new(current_user, organization) }

      it 'should allow to update the organization' do
        expect(subject.update?).to be(false)
      end
    end
  end

  context 'destroy?' do
    context 'by membership' do
      let(:current_user) { create :user }
      let(:organization) { create :organization }
      subject { OrganizationPolicy.new(current_user, organization) }

      %w(write read).each do |role|
        it "with role #{role} should not allow to destroy the organization" do
          organization.add_member(current_user, role)
          expect(subject.destroy?).to be(false)
        end
      end

      it 'with role admin should not allow to destroy the organization' do
        organization.add_member(current_user, 'admin')
        expect(subject.destroy?).to be(true)
      end
    end

    context 'with role admin' do
      let(:current_user) { create :user, role: 'admin' }
      let(:organization) { create :organization }
      subject { OrganizationPolicy.new(current_user, organization) }

      it 'should allow to destroy the organization' do
        expect(subject.destroy?).to be(true)
      end
    end

    context 'with role user' do
      let(:current_user) { create :user, role: 'user' }
      let(:organization) { create :organization }
      subject { OrganizationPolicy.new(current_user, organization) }

      it 'should allow to destroy the organization' do
        expect(subject.destroy?).to be(false)
      end
    end
  end
end
