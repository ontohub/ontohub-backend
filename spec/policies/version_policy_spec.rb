# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VersionPolicy do
  context 'when current_user is a User' do
    let(:user) { create :user }
    let(:admin) { create :user, :admin }

    context 'show?' do
      context 'signed in' do
        subject { VersionPolicy.new(user) }

        it 'allows to show the version' do
          expect(subject.show?).to be(true)
        end
      end

      context 'signed in as admin' do
        subject { VersionPolicy.new(admin) }

        it 'allows to show the version' do
          expect(subject.show?).to be(true)
        end
      end

      context 'not signed in' do
        subject { VersionPolicy.new(nil) }

        it 'allows to show the version' do
          expect(subject.show?).to be(true)
        end
      end
    end
  end

  context 'when current_user is an ApiKey' do
    context 'GitShellApiKey' do
      let(:current_user) { create(:git_shell_api_key) }
      subject do
        VersionPolicy.new(current_user)
      end

      it 'does allow show?' do
        expect(subject.show?).to be(true)
      end
    end

    context 'HetsApiKey' do
      let(:current_user) { create(:hets_api_key) }
      subject do
        VersionPolicy.new(current_user)
      end

      it 'does allow show?' do
        expect(subject.show?).to be(true)
      end
    end
  end
end
