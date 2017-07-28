# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TreePolicy do
  let(:user) { create :user }
  let(:admin) { create :user, :admin }
  let(:public_repo) { create :repository, public_access: true }
  let(:private_repo) { create :repository, public_access: false }
  let(:organization) { create :organization }

  context 'create?' do
    context 'not signed in' do
      subject { TreePolicy.new(nil, public_repo) }

      it 'does not allow to create the tree' do
        expect(subject.create?).to be(false)
      end
    end

    context 'signed in with access' do
      context 'by admin role' do
        subject { TreePolicy.new(admin, public_repo) }

        it 'allows to create the tree' do
          expect(subject.create?).to be(true)
        end
      end

      context 'by repository membership' do
        subject { TreePolicy.new(user, public_repo) }

        %w(write admin).each do |role|
          it "with role #{role} allows to create the tree" do
            public_repo.add_member(user, role)
            expect(subject.create?).to be(true)
          end
        end

        it 'with role read does not allow to create the tree' do
          public_repo.add_member(user, 'read')
          expect(subject.create?).to be(false)
        end
      end

      context 'by organization membership' do
        let(:repository_by_organization) do
          create :repository, owner: organization
        end
        subject { TreePolicy.new(user, repository_by_organization) }

        %w(write admin).each do |role|
          it "with role #{role} allows to create the tree" do
            organization.add_member(user, role)
            expect(subject.create?).to be(true)
          end
        end

        it 'with role read does not allow to create the tree' do
          organization.add_member(user, 'read')
          expect(subject.create?).to be(false)
        end
      end
    end

    context 'signed in without access' do
      subject { TreePolicy.new(user, public_repo) }

      it 'does not allow to create the tree' do
        expect(subject.create?).to be(false)
      end
    end
  end

  context 'show?' do
    context 'public repository' do
      context 'signed in' do
        subject { TreePolicy.new(user, public_repo) }

        it 'allows to show the tree' do
          expect(subject.show?).to be(true)
        end
      end

      context 'signed in as admin' do
        subject { TreePolicy.new(admin, public_repo) }

        it 'allows to show the tree' do
          expect(subject.show?).to be(true)
        end
      end

      context 'not signed in' do
        subject { TreePolicy.new(nil, public_repo) }

        it 'allows to show the tree' do
          expect(subject.show?).to be(true)
        end
      end
    end

    context 'private repository' do
      context 'not signed in' do
        subject { TreePolicy.new(nil, private_repo) }

        it 'does not allow to show the tree' do
          expect(subject.show?).to be(false)
        end
      end

      context 'signed in as admin' do
        subject { TreePolicy.new(admin, private_repo) }

        it 'allows to show the tree' do
          expect(subject.show?).to be(true)
        end
      end

      context 'signed in as user without access' do
        subject { TreePolicy.new(user, private_repo) }

        it 'does not allow to show the tree' do
          expect(subject.show?).to be(false)
        end
      end

      context 'signed in as user with access' do
        context 'by ownership' do
          let(:repository_by_user) do
            create :repository, owner: user
          end
          subject { TreePolicy.new(user, repository_by_user) }

          it 'allows to show the tree' do
            expect(subject.show?).to be(true)
          end
        end

        context 'by repository membership' do
          subject { TreePolicy.new(user, private_repo) }

          %w(admin write read).each do |role|
            it "with role #{role} allows to show the tree" do
              private_repo.add_member(user, role)
              expect(subject.show?).to be(true)
            end
          end
        end

        context 'by organization membership' do
          let(:repository_by_organization) do
            create :repository, owner: organization
          end
          subject { TreePolicy.new(user, repository_by_organization) }

          %w(admin write read).each do |role|
            it "with role #{role} allows to show the tree" do
              organization.add_member(user, role)
              expect(subject.show?).to be(true)
            end
          end
        end
      end
    end
  end

  context 'update?' do
    context 'not signed in' do
      subject { TreePolicy.new(nil, public_repo) }

      it 'does not allow to update the tree' do
        expect(subject.update?).to be(false)
      end
    end

    context 'signed in with access' do
      context 'by admin role' do
        subject { TreePolicy.new(admin, public_repo) }

        it 'allows to update the tree' do
          expect(subject.update?).to be(true)
        end
      end

      context 'by repository membership' do
        subject { TreePolicy.new(user, public_repo) }

        %w(write admin).each do |role|
          it "with role #{role} allows to update the tree" do
            public_repo.add_member(user, role)
            expect(subject.update?).to be(true)
          end
        end

        it 'with role read does not allow to update the tree' do
          public_repo.add_member(user, 'read')
          expect(subject.update?).to be(false)
        end
      end

      context 'by organization membership' do
        let(:repository_by_organization) do
          create :repository, owner: organization
        end
        subject { TreePolicy.new(user, repository_by_organization) }

        %w(write admin).each do |role|
          it "with role #{role} allows to update the tree" do
            organization.add_member(user, role)
            expect(subject.update?).to be(true)
          end
        end

        it 'with role read does not allow to update the tree' do
          organization.add_member(user, 'read')
          expect(subject.update?).to be(false)
        end
      end
    end

    context 'signed in without access' do
      subject { TreePolicy.new(user, public_repo) }

      it 'does not allow to update the tree' do
        expect(subject.update?).to be(false)
      end
    end
  end

  context 'destroy?' do
    context 'not signed in' do
      subject { TreePolicy.new(nil, public_repo) }

      it 'does not allow to destroy the tree' do
        expect(subject.destroy?).to be(false)
      end
    end

    context 'signed in with access' do
      context 'by admin role' do
        subject { TreePolicy.new(admin, public_repo) }

        it 'allows to update the tree' do
          expect(subject.destroy?).to be(true)
        end
      end

      context 'by repository membership' do
        subject { TreePolicy.new(user, public_repo) }

        %w(write admin).each do |role|
          it "with role #{role} allows to destroy the tree" do
            public_repo.add_member(user, role)
            expect(subject.destroy?).to be(true)
          end
        end

        it 'with role read does not allow to destroy the tree' do
          public_repo.add_member(user, 'read')
          expect(subject.destroy?).to be(false)
        end
      end

      context 'by organization membership' do
        let(:repository_by_organization) do
          create :repository, owner: organization
        end
        subject { TreePolicy.new(user, repository_by_organization) }

        %w(write admin).each do |role|
          it "with role #{role} allows to destroy the tree" do
            organization.add_member(user, role)
            expect(subject.destroy?).to be(true)
          end
        end

        it 'with role read does not allow to destroy the tree' do
          organization.add_member(user, 'read')
          expect(subject.destroy?).to be(false)
        end
      end
    end

    context 'signed in without access' do
      subject { TreePolicy.new(user, public_repo) }

      it 'does not allow to destroy the tree' do
        expect(subject.destroy?).to be(false)
      end
    end
  end

  context 'multi_action?' do
    context 'not signed in' do
      subject { TreePolicy.new(nil, public_repo) }

      it 'does not allow to commit the tree' do
        expect(subject.multi_action?).to be(false)
      end
    end

    context 'signed in with access' do
      context 'by admin role' do
        subject { TreePolicy.new(admin, public_repo) }

        it 'allows to commit the tree' do
          expect(subject.multi_action?).to be(true)
        end
      end

      context 'by repository membership' do
        subject { TreePolicy.new(user, public_repo) }

        %w(write admin).each do |role|
          it "with role #{role} allows to commit the tree" do
            public_repo.add_member(user, role)
            expect(subject.multi_action?).to be(true)
          end
        end

        it 'with role read does not allow to commit the tree' do
          public_repo.add_member(user, 'read')
          expect(subject.multi_action?).to be(false)
        end
      end

      context 'by organization membership' do
        let(:repository_by_organization) do
          create :repository, owner: organization
        end
        subject { TreePolicy.new(user, repository_by_organization) }

        %w(write admin).each do |role|
          it "with role #{role} allows to commit the tree" do
            organization.add_member(user, role)
            expect(subject.multi_action?).to be(true)
          end
        end

        it 'with role read does not allow to commit the tree' do
          organization.add_member(user, 'read')
          expect(subject.multi_action?).to be(false)
        end
      end
    end

    context 'signed in without access' do
      subject { TreePolicy.new(user, public_repo) }

      it 'does not allow to commit the tree' do
        expect(subject.multi_action?).to be(false)
      end
    end
  end
end
