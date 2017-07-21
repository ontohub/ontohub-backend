# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TreePolicy do
  context 'create?' do
    let(:repository) { create :repository, public_access: true }

    context 'not signed in' do
      let(:current_user) { nil }
      subject { TreePolicy.new(current_user, repository) }

      it 'should not allow to create the tree' do
        expect(subject.create?).to be(false)
      end
    end

    context 'signed in with access' do
      context 'by admin role' do
        let(:current_user) { create :user, :admin }
        subject { TreePolicy.new(current_user, repository) }

        it 'should allow to create the tree' do
          expect(subject.create?).to be(true)
        end
      end

      context 'by repository membership' do
        let(:current_user) { create :user }
        subject { TreePolicy.new(current_user, repository) }

        %w(write admin).each do |role|
          it "with role #{role} should allow to create the tree" do
            repository.add_member(current_user, role)
            expect(subject.create?).to be(true)
          end
        end

        it 'with role read should not allow to create the tree' do
          repository.add_member(current_user, 'read')
          expect(subject.create?).to be(false)
        end
      end

      context 'by organization membership' do
        let(:current_user) { create :user }
        let(:organization) { create :organization }
        let(:repository_by_organization) do
          create :repository, owner: organization
        end
        subject { TreePolicy.new(current_user, repository_by_organization) }

        %w(write admin).each do |role|
          it "with role #{role} should allow to create the tree" do
            organization.add_member(current_user, role)
            expect(subject.create?).to be(true)
          end
        end

        it 'with role read should not allow to create the tree' do
          organization.add_member(current_user, 'read')
          expect(subject.create?).to be(false)
        end
      end
    end

    context 'signed in without access' do
      let(:current_user) { create :user }
      subject { TreePolicy.new(current_user, repository) }

      it 'should not allow to create the tree' do
        expect(subject.create?).to be(false)
      end
    end
  end

  context 'show?' do
    context 'public repository' do
      let(:repository) { create :repository, public_access: true }

      context 'signed in' do
        let(:current_user) { create :user }
        subject { TreePolicy.new(current_user, repository) }

        it 'should allow to show the tree' do
          expect(subject.show?).to be(true)
        end
      end

      context 'signed in as admin' do
        let(:current_user) { create :user, :admin }
        subject { TreePolicy.new(current_user, repository) }

        it 'should allow to show the tree' do
          expect(subject.show?).to be(true)
        end
      end

      context 'not signed in' do
        let(:current_user) { nil }
        subject { TreePolicy.new(current_user, repository) }

        it 'should allow to show the tree' do
          expect(subject.show?).to be(true)
        end
      end
    end

    context 'private repository' do
      let!(:repository) { create :repository, public_access: false }

      context 'not signed in' do
        let(:current_user) { nil }
        subject { TreePolicy.new(current_user, repository) }

        it 'should not allow to show the tree' do
          expect(subject.show?).to be(false)
        end
      end

      context 'signed in as admin' do
        let(:current_user) { create :user, :admin }
        subject { TreePolicy.new(current_user, repository) }

        it 'should allow to show the tree' do
          expect(subject.show?).to be(true)
        end
      end

      context 'signed in as user without access' do
        let(:current_user) { create :user }
        subject { TreePolicy.new(current_user, repository) }

        it 'should not allow to show the tree' do
          expect(subject.show?).to be(false)
        end
      end

      context 'signed in as user with access' do
        context 'by ownership' do
          let(:current_user) { create :user }
          let(:repository_by_user) do
            create :repository, owner: current_user
          end
          subject { TreePolicy.new(current_user, repository_by_user) }

          it 'should allow to show the tree' do
            expect(subject.show?).to be(true)
          end
        end

        context 'by repository membership' do
          let(:current_user) { create :user }
          subject { TreePolicy.new(current_user, repository) }

          %w(admin write read).each do |role|
            it "with role #{role} should allow to show the tree" do
              repository.add_member(current_user, role)
              expect(subject.show?).to be(true)
            end
          end
        end

        context 'by organization membership' do
          let(:current_user) { create :user }
          let(:organization) { create :organization }
          let(:repository_by_organization) do
            create :repository, owner: organization
          end
          subject { TreePolicy.new(current_user, repository_by_organization) }

          %w(admin write read).each do |role|
            it "with role #{role} should allow to show the tree" do
              organization.add_member(current_user, role)
              expect(subject.show?).to be(true)
            end
          end
        end
      end
    end
  end

  context 'update?' do
    let(:repository) { create :repository, public_access: true }

    context 'not signed in' do
      let(:current_user) { nil }
      subject { TreePolicy.new(current_user, repository) }

      it 'should not allow to update the tree' do
        expect(subject.update?).to be(false)
      end
    end

    context 'signed in with access' do
      context 'by admin role' do
        let(:current_user) { create :user, :admin }
        subject { TreePolicy.new(current_user, repository) }

        it 'should allow to update the tree' do
          expect(subject.update?).to be(true)
        end
      end

      context 'by repository membership' do
        let(:current_user) { create :user }
        subject { TreePolicy.new(current_user, repository) }

        %w(write admin).each do |role|
          it "with role #{role} should allow to update the tree" do
            repository.add_member(current_user, role)
            expect(subject.update?).to be(true)
          end
        end

        it 'with role read should not allow to update the tree' do
          repository.add_member(current_user, 'read')
          expect(subject.update?).to be(false)
        end
      end

      context 'by organization membership' do
        let(:current_user) { create :user }
        let(:organization) { create :organization }
        let(:repository_by_organization) do
          create :repository, owner: organization
        end
        subject { TreePolicy.new(current_user, repository_by_organization) }

        %w(write admin).each do |role|
          it "with role #{role} should allow to update the tree" do
            organization.add_member(current_user, role)
            expect(subject.update?).to be(true)
          end
        end

        it 'with role read should not allow to update the tree' do
          organization.add_member(current_user, 'read')
          expect(subject.update?).to be(false)
        end
      end
    end

    context 'signed in without access' do
      let(:current_user) { create :user }
      subject { TreePolicy.new(current_user, repository) }

      it 'should not allow to update the tree' do
        expect(subject.update?).to be(false)
      end
    end
  end

  context 'destroy?' do
    let(:repository) { create :repository, public_access: true }

    context 'not signed in' do
      let(:current_user) { nil }
      subject { TreePolicy.new(current_user, repository) }

      it 'should not allow to destroy the tree' do
        expect(subject.destroy?).to be(false)
      end
    end

    context 'signed in with access' do
      context 'by admin role' do
        let(:current_user) { create :user, :admin }
        subject { TreePolicy.new(current_user, repository) }

        it 'should allow to update the tree' do
          expect(subject.destroy?).to be(true)
        end
      end

      context 'by repository membership' do
        let(:current_user) { create :user }
        subject { TreePolicy.new(current_user, repository) }

        %w(write admin).each do |role|
          it "with role #{role} should allow to destroy the tree" do
            repository.add_member(current_user, role)
            expect(subject.destroy?).to be(true)
          end
        end

        it 'with role read should not allow to destroy the tree' do
          repository.add_member(current_user, 'read')
          expect(subject.destroy?).to be(false)
        end
      end

      context 'by organization membership' do
        let(:current_user) { create :user }
        let(:organization) { create :organization }
        let(:repository_by_organization) do
          create :repository, owner: organization
        end
        subject { TreePolicy.new(current_user, repository_by_organization) }

        %w(write admin).each do |role|
          it "with role #{role} should allow to destroy the tree" do
            organization.add_member(current_user, role)
            expect(subject.destroy?).to be(true)
          end
        end

        it 'with role read should not allow to destroy the tree' do
          organization.add_member(current_user, 'read')
          expect(subject.destroy?).to be(false)
        end
      end
    end

    context 'signed in without access' do
      let(:current_user) { create :user }
      subject { TreePolicy.new(current_user, repository) }

      it 'should not allow to destroy the tree' do
        expect(subject.destroy?).to be(false)
      end
    end
  end

  context 'multi_action?' do
    let(:repository) { create :repository, public_access: true }

    context 'not signed in' do
      let(:current_user) { nil }
      subject { TreePolicy.new(current_user, repository) }

      it 'should not allow to commit the tree' do
        expect(subject.multi_action?).to be(false)
      end
    end

    context 'signed in with access' do
      context 'by admin role' do
        let(:current_user) { create :user, :admin }
        subject { TreePolicy.new(current_user, repository) }

        it 'should allow to commit the tree' do
          expect(subject.multi_action?).to be(true)
        end
      end

      context 'by repository membership' do
        let(:current_user) { create :user }
        subject { TreePolicy.new(current_user, repository) }

        %w(write admin).each do |role|
          it "with role #{role} should allow to commit the tree" do
            repository.add_member(current_user, role)
            expect(subject.multi_action?).to be(true)
          end
        end

        it 'with role read should not allow to commit the tree' do
          repository.add_member(current_user, 'read')
          expect(subject.multi_action?).to be(false)
        end
      end

      context 'by organization membership' do
        let(:current_user) { create :user }
        let(:organization) { create :organization }
        let(:repository_by_organization) do
          create :repository, owner: organization
        end
        subject { TreePolicy.new(current_user, repository_by_organization) }

        %w(write admin).each do |role|
          it "with role #{role} should allow to commit the tree" do
            organization.add_member(current_user, role)
            expect(subject.multi_action?).to be(true)
          end
        end

        it 'with role read should not allow to commit the tree' do
          organization.add_member(current_user, 'read')
          expect(subject.multi_action?).to be(false)
        end
      end
    end

    context 'signed in without access' do
      let(:current_user) { create :user }
      subject { TreePolicy.new(current_user, repository) }

      it 'should not allow to commit the tree' do
        expect(subject.multi_action?).to be(false)
      end
    end
  end
end
