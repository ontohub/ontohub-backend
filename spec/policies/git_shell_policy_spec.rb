# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GitShellPolicy do
  context 'when current_user is a User' do
    let(:user) { create :user }
    let(:admin) { create :user, :admin }

    context 'authorize?' do
      context 'signed in' do
        subject { GitShellPolicy.new(user) }

        it 'allows to authorize the version' do
          expect(subject.authorize?).to be(false)
        end
      end

      context 'signed in as admin' do
        subject { GitShellPolicy.new(admin) }

        it 'allows to authorize the version' do
          expect(subject.authorize?).to be(true)
        end
      end

      context 'not signed in' do
        subject { GitShellPolicy.new(nil) }

        it 'allows to authorize the version' do
          expect(subject.authorize?).to be(false)
        end
      end
    end
  end

  context 'when current_user is an ApiKey' do
    context 'GitShellApiKey' do
      let(:current_user) { create(:git_shell_api_key) }
      subject do
        GitShellPolicy.new(current_user)
      end

      it 'does allow authorize?' do
        foo = subject.authorize?
        expect(subject.authorize?).to be(true)
      end
    end

    context 'HetsApiKey' do
      let(:current_user) { create(:hets_api_key) }
      subject do
        GitShellPolicy.new(current_user)
      end

      it 'does not allow authorize?' do
        expect(subject.authorize?).to be(false)
      end
    end
  end
end
