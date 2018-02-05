# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy do
  context 'when current_user is a User' do
    let(:user) { create :user }
    let(:admin) { create :user, :admin }
    let(:other_user) { create :user }

    context 'show?' do
      context 'signed in' do
        subject { UserPolicy.new(user, other_user) }

        it 'allows to show the user' do
          expect(subject.show?).to be(true)
        end
      end

      context 'signed in as admin' do
        subject { UserPolicy.new(admin, other_user) }

        it 'allows to show the user' do
          expect(subject.show?).to be(true)
        end
      end

      context 'not signed in' do
        subject { UserPolicy.new(nil, other_user) }

        it 'allows to show the user' do
          expect(subject.show?).to be(true)
        end
      end
    end

    context 'show_current_user?' do
      context 'signed in' do
        subject { UserPolicy.new(user, other_user) }

        it 'allows to show the user' do
          expect(subject.show_current_user?).to be(true)
        end
      end

      context 'signed in as admin' do
        subject { UserPolicy.new(admin, other_user) }

        it 'allows to show the user' do
          expect(subject.show_current_user?).to be(true)
        end
      end

      context 'not signed in' do
        subject { UserPolicy.new(nil, other_user) }

        it 'does not allow to show the user' do
          expect(subject.show_current_user?).to be(false)
        end
      end
    end

    context 'access_private_data?' do
      context 'signed in as admin' do
        subject { UserPolicy.new(admin, other_user) }

        it 'allows to see the users private data' do
          expect(subject.access_private_data?).to be(true)
        end
      end

      context 'signed in' do
        context 'own email' do
          subject { UserPolicy.new(user, user) }

          it 'allows to see my private data' do
            expect(subject.access_private_data?).to be(true)
          end
        end

        context 'other users email' do
          subject { UserPolicy.new(user, other_user) }

          it 'does not allow to see the users private data' do
            expect(subject.access_private_data?).to be(false)
          end
        end
      end

      context 'not signed in' do
        subject { UserPolicy.new(nil, other_user) }

        it 'does not allow to see the users private data' do
          expect(subject.access_private_data?).to be(false)
        end
      end
    end
  end

  context 'when current_user is an ApiKey' do
    context 'GitShellApiKey' do
      let(:current_user) { create(:git_shell_api_key) }
      subject do
        UserPolicy.new(current_user)
      end

      %i(show? show_current_user? access_private_data?).each do |method|
        it "does not allow #{method}" do
          expect(subject.public_send(method)).to be(false)
        end
      end
    end

    context 'HetsApiKey' do
      let(:current_user) { create(:hets_api_key) }
      subject do
        UserPolicy.new(current_user)
      end

      %i(show_current_user? access_private_data?).each do |method|
        it "does not allow #{method}" do
          expect(subject.public_send(method)).to be(false)
        end
      end

      it 'does allow show?' do
        expect(subject.show?).to be(true)
      end
    end
  end
end
