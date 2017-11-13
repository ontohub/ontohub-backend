# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RepositoryPolicy do
  let(:user) { create :user }
  let(:admin) { create :user, :admin }
  let(:public_repo) { create :repository, public_access: true }
  let(:private_repo) { create :repository, public_access: false }
  let(:organization) { create :organization }

  describe RepositoryPolicy::Scope do
    subject { RepositoryPolicy::Scope.new(current_user, scope) }
    let(:scope) { Repository.dataset }

    before do
      2.times do
        create(:repository, public_access: false)
      end
      3.times do
        create(:repository, public_access: true)
      end
      2.times do
        repo = create(:repository, public_access: false)
        repo.add_member(user, :read)
      end
    end

    context 'signed in as admin' do
      let(:current_user) { admin }

      it 'returns all repositories' do
        expect(subject.resolve.to_a.size).to eq(7)
      end
    end

    context 'signed in as normal user' do
      let(:current_user) { user }

      it 'returns public repositories and ones with explicit access' do
        expect(subject.resolve.to_a.size).to eq(5)
      end
    end

    context 'not signed in' do
      let(:current_user) { nil }

      it 'returns only public repositories' do
        expect(subject.resolve.to_a.size).to eq(3)
      end
    end
  end

  context 'show?' do
    context 'no repository' do
      subject { RepositoryPolicy.new(user, nil) }

      it 'returns false' do
        expect(subject.show?).to be(false)
      end
    end

    context 'public repository' do
      context 'signed in' do
        subject { RepositoryPolicy.new(user, public_repo) }

        it 'allows to show the repository' do
          expect(subject.show?).to be(true)
        end
      end

      context 'signed in as admin' do
        subject { RepositoryPolicy.new(admin, public_repo) }

        it 'allows to show the repository' do
          expect(subject.show?).to be(true)
        end
      end

      context 'not signed in' do
        subject { RepositoryPolicy.new(nil, public_repo) }

        it 'allows to show the repository' do
          expect(subject.show?).to be(true)
        end
      end
    end

    context 'private repository' do
      context 'not signed in' do
        subject { RepositoryPolicy.new(nil, private_repo) }

        it 'does not allow to show the repository' do
          expect(subject.show?).to be(false)
        end
      end

      context 'signed in as admin' do
        subject { RepositoryPolicy.new(admin, private_repo) }

        it 'allows to show the repository' do
          expect(subject.show?).to be(true)
        end
      end

      context 'signed in as user without access' do
        subject { RepositoryPolicy.new(user, private_repo) }

        it 'does not allow to show the repository' do
          expect(subject.show?).to be(false)
        end
      end

      context 'signed in as user with access' do
        context 'by ownership' do
          let(:repository_by_user) do
            create :repository, public_access: false, owner: user
          end
          subject { RepositoryPolicy.new(user, repository_by_user) }

          it 'allows to show the repository' do
            expect(subject.show?).to be(true)
          end
        end

        context 'by repository membership' do
          subject { RepositoryPolicy.new(user, private_repo) }

          %w(admin write read).each do |role|
            it "with role #{role} allows to show the repository" do
              private_repo.add_member(user, role)
              expect(subject.show?).to be(true)
            end
          end
        end

        context 'by organization membership' do
          let(:repository_by_organization) do
            create :repository, public_access: false, owner: organization
          end
          subject do
            RepositoryPolicy.new(user, repository_by_organization)
          end

          %w(admin write read).each do |role|
            it "with role #{role} allows to show the repository" do
              organization.add_member(user, role)
              expect(subject.show?).to be(true)
            end
          end
        end
      end
    end
  end

  context 'create?' do
    context 'owner is current user' do
      context 'not signed in' do
        subject { RepositoryPolicy.new(nil, public_repo) }

        it 'does not allow to create the repository' do
          expect(subject.create?(nil)).to be(false)
        end
      end

      context 'signed in' do
        context 'as admin role' do
          subject { RepositoryPolicy.new(admin, public_repo) }

          it 'allows to create the repository' do
            expect(subject.create?(admin)).to be(true)
          end
        end

        context 'as user role' do
          subject { RepositoryPolicy.new(user, public_repo) }

          it 'allows to create the repository' do
            expect(subject.create?(user)).to be(true)
          end
        end
      end
    end

    context 'owner is organization' do
      subject { RepositoryPolicy.new(user, Repository) }

      %w(write read).each do |role|
        it "with role #{role} does not allow to create the repository" do
          organization.add_member(user, role)
          expect(subject.create?(organization)).to be(false)
        end
      end

      context 'as an organization admin' do
        it 'allows to create the repository' do
          organization.add_member(user, 'admin')
          expect(subject.create?(organization)).to be(true)
        end
      end

      context 'unrelated to the organization' do
        it 'does not allow to create the repository' do
          expect(subject.create?(organization)).to be(false)
        end
      end
    end

    context 'owner does not exist' do
      subject { RepositoryPolicy.new(user, Repository) }

      it 'does not allow to create the repository' do
        expect(subject.create?(nil)).to be(false)
      end
    end
  end

  context 'update?' do
    [true, false].each do |public|
      context "with public access #{public}" do
        let(:repository) { create :repository, public_access: public }

        context 'not signed in' do
          subject { RepositoryPolicy.new(nil, repository) }

          it 'does not allow to update the repository' do
            expect(subject.update?).to be(false)
          end
        end

        context 'signed in' do
          context 'as admin role' do
            subject { RepositoryPolicy.new(admin, repository) }

            it 'allows to update the repository' do
              expect(subject.update?).to be(true)
            end
          end

          context 'as user role without access' do
            subject { RepositoryPolicy.new(user, repository) }

            it 'does not allow to update the repository' do
              expect(subject.update?).to be(false)
            end
          end

          context 'as a user role with access' do
            context 'by ownership' do
              let(:repository_by_user) do
                create :repository, owner: user
              end
              subject { RepositoryPolicy.new(user, repository_by_user) }

              it 'allows to update the repository' do
                expect(subject.update?).to be(true)
              end
            end

            context 'by repository membership' do
              subject { RepositoryPolicy.new(user, repository) }

              %w(write read).each do |role|
                it "with role #{role} does not allow to update the "\
                  'repository' do
                  repository.add_member(user, role)
                  expect(subject.update?).to be(false)
                end
              end

              it 'with role admin allows to update the repository' do
                repository.add_member(user, 'admin')
                expect(subject.update?).to be(true)
              end
            end

            context 'by organization membership' do
              let(:repository_by_organization) do
                create :repository, owner: organization
              end
              subject do
                RepositoryPolicy.new(user, repository_by_organization)
              end

              %w(write read).each do |role|
                it "with role #{role} does not allow to update the "\
                  'repository' do
                  organization.add_member(user, role)
                  expect(subject.update?).to be(false)
                end
              end

              it 'with role admin allows to update the repository' do
                organization.add_member(user, 'admin')
                expect(subject.update?).to be(true)
              end
            end
          end
        end
      end
    end
  end

  context 'index?' do
    [true, false].each do |public|
      context "with public access #{public}" do
        let(:repository) { create :repository, public_access: public }

        context 'not signed in' do
          subject { RepositoryPolicy.new(nil, repository) }

          it 'allows to list the repository' do
            expect(subject.index?).to be(true)
          end
        end

        context 'signed in' do
          context 'as user role' do
            subject { RepositoryPolicy.new(user, repository) }

            it 'allows to list the repository' do
              expect(subject.index?).to be(true)
            end
          end

          context 'as admin role' do
            subject { RepositoryPolicy.new(admin, repository) }

            it 'allows to list the repository' do
              expect(subject.index?).to be(true)
            end
          end
        end
      end
    end
  end

  context 'write?' do
    [true, false].each do |public_access|
      context "with public access #{public_access}" do
        let(:repository) { create :repository, public_access: public_access }

        context 'not signed in' do
          subject { RepositoryPolicy.new(nil, repository) }

          it 'does not allow to write to the repository' do
            expect(subject.write?).to be(false)
          end
        end

        context 'signed in' do
          context 'as admin role' do
            subject { RepositoryPolicy.new(admin, repository) }

            it 'allows to write to the repository' do
              expect(subject.write?).to be(true)
            end
          end

          context 'as a user role without access' do
            subject { RepositoryPolicy.new(user, repository) }

            it 'does not allow to write to the repository' do
              expect(subject.write?).to be(false)
            end
          end

          context 'as a user role with access' do
            context 'by ownership' do
              let(:repository_by_user) do
                create :repository, owner: user
              end
              subject { RepositoryPolicy.new(user, repository_by_user) }

              it 'allows to write to the repository' do
                expect(subject.write?).to be(true)
              end
            end

            context 'by repository membership' do
              subject { RepositoryPolicy.new(user, repository) }

              %w(admin write).each do |role|
                it "with role #{role} allows to write to the "\
                  'repository' do
                  repository.add_member(user, role)
                  expect(subject.write?).to be(true)
                end
              end

              it 'with role read does not allow to write the repository' do
                repository.add_member(user, 'read')
                expect(subject.write?).to be(false)
              end
            end

            context 'by organization membership' do
              let(:repository_by_organization) do
                create :repository, owner: organization
              end
              subject do
                RepositoryPolicy.new(user, repository_by_organization)
              end

              %w(admin write).each do |role|
                it "with role #{role} allows to write to the "\
                  'repository' do
                  organization.add_member(user, role)
                  expect(subject.write?).to be(true)
                end
              end

              it 'with role read does not allow to write to the repository' do
                organization.add_member(user, 'read')
                expect(subject.write?).to be(false)
              end
            end
          end
        end
      end
    end
  end

  context 'destroy?' do
    [true, false].each do |public_access|
      context "with public access #{public_access}" do
        let(:repository) { create :repository, public_access: public_access }

        context 'not signed in' do
          subject { RepositoryPolicy.new(nil, repository) }

          it 'does not allow to destroy the repository' do
            expect(subject.destroy?).to be(false)
          end
        end

        context 'signed in' do
          context 'as admin role' do
            subject { RepositoryPolicy.new(admin, repository) }

            it 'allows to destroy the repository' do
              expect(subject.destroy?).to be(true)
            end
          end

          context 'as user role without access' do
            subject { RepositoryPolicy.new(user, repository) }

            it 'does not allow to destroy the repository' do
              expect(subject.destroy?).to be(false)
            end
          end

          context 'as a user role with access' do
            context 'by ownership' do
              let(:repository_by_user) do
                create :repository, owner: user
              end
              subject { RepositoryPolicy.new(user, repository_by_user) }

              it 'allows to destroy the repository' do
                expect(subject.destroy?).to be(true)
              end
            end

            context 'by repository membership' do
              subject { RepositoryPolicy.new(user, repository) }

              %w(write read).each do |role|
                it "with role #{role} does not allow to destroy the "\
                  'repository' do
                  repository.add_member(user, role)
                  expect(subject.destroy?).to be(false)
                end
              end

              it 'with role admin allows to destroy the repository' do
                repository.add_member(user, 'admin')
                expect(subject.destroy?).to be(true)
              end
            end

            context 'by organization membership' do
              let(:repository_by_organization) do
                create :repository, owner: organization
              end
              subject do
                RepositoryPolicy.new(user, repository_by_organization)
              end

              %w(write read).each do |role|
                it "with role #{role} does not allow to destroy the "\
                  'repository' do
                  organization.add_member(user, role)
                  expect(subject.destroy?).to be(false)
                end
              end

              it 'with role admin allows to destroy the repository' do
                organization.add_member(user, 'admin')
                expect(subject.destroy?).to be(true)
              end
            end
          end
        end
      end
    end
  end
end
