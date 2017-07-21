# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RepositoryPolicy do
  context 'show?' do
    context 'public repository' do
      let(:repository) { create :repository, public_access: true }

      context 'signed in' do
        let(:current_user) { create :user }
        subject { RepositoryPolicy.new(current_user, repository) }

        it 'should allow to show the repository' do
          expect(subject.show?).to be(true)
        end
      end

      context 'signed in as admin' do
        let(:current_user) { create :user, :admin }
        subject { RepositoryPolicy.new(current_user, repository) }

        it 'should allow to show the repository' do
          expect(subject.show?).to be(true)
        end
      end

      context 'not signed in' do
        let(:current_user) { nil }
        subject { RepositoryPolicy.new(current_user, repository) }

        it 'should allow to show the repository' do
          expect(subject.show?).to be(true)
        end
      end
    end

    context 'private repository' do
      let!(:repository) { create :repository, public_access: false }

      context 'not signed in' do
        let(:current_user) { nil }
        subject { RepositoryPolicy.new(current_user, repository) }

        it 'should not allow to show the repository' do
          expect(subject.show?).to be(false)
        end
      end

      context 'signed in as admin' do
        let(:current_user) { create :user, :admin }
        subject { RepositoryPolicy.new(current_user, repository) }

        it 'should allow to show the repository' do
          expect(subject.show?).to be(true)
        end
      end

      context 'signed in as user without access' do
        let(:current_user) { create :user }
        subject { RepositoryPolicy.new(current_user, repository) }

        it 'should not allow to show the repository' do
          expect(subject.show?).to be(false)
        end
      end

      context 'signed in as user with access' do
        context 'by ownership' do
          let(:current_user) { create :user }
          let(:repository_by_user) do
            create :repository, owner: current_user
          end
          subject { RepositoryPolicy.new(current_user, repository_by_user) }

          it 'should allow to show the repository' do
            expect(subject.show?).to be(true)
          end
        end

        context 'by repository membership' do
          let(:current_user) { create :user }
          subject { RepositoryPolicy.new(current_user, repository) }

          %w(admin write read).each do |role|
            it "with role #{role} should allow to show the repository" do
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
          subject do
            RepositoryPolicy.new(current_user, repository_by_organization)
          end

          %w(admin write read).each do |role|
            it "with role #{role} should allow to show the repository" do
              organization.add_member(current_user, role)
              expect(subject.show?).to be(true)
            end
          end
        end
      end
    end
  end

  context 'create?' do
    let(:repository) { create :repository, public_access: true }

    context 'owner is current user' do
      context 'not signed in' do
        let(:current_user) { nil }
        subject { RepositoryPolicy.new(current_user, repository) }

        it 'should not allow to create the repository' do
          expect(subject.create?(current_user)).to be(false)
        end
      end

      context 'signed in' do
        context 'as admin role' do
          let(:current_user) { create :user, :admin }
          subject { RepositoryPolicy.new(current_user, repository) }

          it 'should allow to create the repository' do
            expect(subject.create?(current_user)).to be(true)
          end
        end

        context 'as user role' do
          let(:current_user) { create :user }
          subject { RepositoryPolicy.new(current_user, repository) }

          it 'should allow to create the repository' do
            expect(subject.create?(current_user)).to be(true)
          end
        end
      end
    end

    context 'owner is organization' do
      let(:current_user) { create :user }
      let(:organization) { create :organization }
      subject { RepositoryPolicy.new(current_user, Repository) }

      %w(write read).each do |role|
        it "with role #{role} should not allow to create the repository" do
          organization.add_member(current_user, role)
          expect(subject.create?(organization)).to be(false)
        end
      end

      context 'as an organization admin' do
        it 'should allow to create the repository' do
          organization.add_member(current_user, 'admin')
          expect(subject.create?(organization)).to be(true)
        end
      end

      context 'unrelated to the organization' do
        it 'should not allow to create the repository' do
          expect(subject.create?(organization)).to be(false)
        end
      end
    end
  end

  context 'update?' do
    [true, false].each do |public|
      context "with public access #{public}" do
        let(:repository) { create :repository, public_access: public }

        context 'not signed in' do
          let(:current_user) { nil }
          subject { RepositoryPolicy.new(current_user, repository) }

          it 'should not allow to update the repository' do
            expect(subject.update?).to be(false)
          end
        end

        context 'signed in' do
          context 'as admin role' do
            let(:current_user) { create :user, :admin }
            subject { RepositoryPolicy.new(current_user, repository) }

            it 'should allow to update the repository' do
              expect(subject.update?).to be(true)
            end
          end

          context 'as user role without access' do
            let(:current_user) { create :user }
            subject { RepositoryPolicy.new(current_user, repository) }

            it 'should not allow to update the repository' do
              expect(subject.update?).to be(false)
            end
          end

          context 'as a user role with access' do
            context 'by ownership' do
              let(:current_user) { create :user }
              let(:repository_by_user) do
                create :repository, owner: current_user
              end
              subject { RepositoryPolicy.new(current_user, repository_by_user) }

              it 'should allow to update the repository' do
                expect(subject.update?).to be(true)
              end
            end

            context 'by repository membership' do
              let(:current_user) { create :user }
              subject { RepositoryPolicy.new(current_user, repository) }

              %w(write read).each do |role|
                it "with role #{role} should not allow to update the " +
                  "repository" do
                  repository.add_member(current_user, role)
                  expect(subject.update?).to be(false)
                end
              end

              it 'with role admin should allow to update the repository' do
                repository.add_member(current_user, 'admin')
                expect(subject.update?).to be(true)
              end
            end

            context 'by organization membership' do
              let(:current_user) { create :user }
              let(:organization) { create :organization }
              let(:repository_by_organization) do
                create :repository, owner: organization
              end
              subject do
                RepositoryPolicy.new(current_user, repository_by_organization)
              end

              %w(write read).each do |role|
                it "with role #{role} should not allow to update the " +
                  "repository" do
                  organization.add_member(current_user, role)
                  expect(subject.update?).to be(false)
                end
              end

              it 'with role admin should allow to update the repository' do
                organization.add_member(current_user, 'admin')
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
          let(:current_user) { nil }
          subject { RepositoryPolicy.new(current_user, repository) }

          it 'should allow to index the repository' do
            expect(subject.index?).to be(true)
          end
        end

        context 'signed in' do
          context 'as user role' do
            let(:current_user) { create :user }
            subject { RepositoryPolicy.new(current_user, repository) }

            it 'should allow to index the repository' do
              expect(subject.index?).to be(true)
            end
          end

          context 'as admin role' do
            let(:current_user) { create :user, :admin }
            subject { RepositoryPolicy.new(current_user, repository) }

            it 'should allow to index the repository' do
              expect(subject.index?).to be(true)
            end
          end
        end
      end
    end
  end

  context 'destroy?' do
    [true, false].each do |public|
      context "with public access #{public}" do
        let(:repository) { create :repository, public_access: public }

        context 'not signed in' do
          let(:current_user) { nil }
          subject { RepositoryPolicy.new(current_user, repository) }

          it 'should not allow to destroy the repository' do
            expect(subject.destroy?).to be(false)
          end
        end

        context 'signed in' do
          context 'as admin role' do
            let(:current_user) { create :user, :admin }
            subject { RepositoryPolicy.new(current_user, repository) }

            it 'should allow to destroy the repository' do
              expect(subject.destroy?).to be(true)
            end
          end

          context 'as user role without access' do
            let(:current_user) { create :user }
            subject { RepositoryPolicy.new(current_user, repository) }

            it 'should not allow to destroy the repository' do
              expect(subject.destroy?).to be(false)
            end
          end

          context 'as a user role with access' do
            context 'by ownership' do
              let(:current_user) { create :user }
              let(:repository_by_user) do
                create :repository, owner: current_user
              end
              subject { RepositoryPolicy.new(current_user, repository_by_user) }

              it 'should allow to destroy the repository' do
                expect(subject.destroy?).to be(true)
              end
            end

            context 'by repository membership' do
              let(:current_user) { create :user }
              subject { RepositoryPolicy.new(current_user, repository) }

              %w(write read).each do |role|
                it "with role #{role} should not allow to destroy the " +          "repository" do
                  repository.add_member(current_user, role)
                  expect(subject.destroy?).to be(false)
                end
              end

              it 'with role admin should allow to destroy the repository' do
                repository.add_member(current_user, 'admin')
                expect(subject.destroy?).to be(true)
              end
            end

            context 'by organization membership' do
              let(:current_user) { create :user }
              let(:organization) { create :organization }
              let(:repository_by_organization) do
                create :repository, owner: organization
              end
              subject do
                RepositoryPolicy.new(current_user, repository_by_organization)
              end

              %w(write read).each do |role|
                it "with role #{role} should not allow to destroy the "\
                  "repository" do
                  organization.add_member(current_user, role)
                  expect(subject.destroy?).to be(false)
                end
              end

              it 'with role admin should allow to destroy the repository' do
                organization.add_member(current_user, 'admin')
                expect(subject.destroy?).to be(true)
              end
            end
          end
        end
      end
    end
  end
end
