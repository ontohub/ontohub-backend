# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchResultPolicy do
  context 'when current_user is a User' do
    let(:user) { create :user }
    let(:admin) { create :user, :admin }

    context 'search?' do
      context 'signed in' do
        subject { SearchResultPolicy.new(user) }

        it 'allows to search' do
          expect(subject.search?).to be(true)
        end
      end

      context 'signed in as admin' do
        subject { SearchResultPolicy.new(admin) }

        it 'allows to search' do
          expect(subject.search?).to be(true)
        end
      end

      context 'not signed in' do
        subject { SearchResultPolicy.new(nil) }

        it 'allows to search' do
          expect(subject.search?).to be(true)
        end
      end
    end
  end

  context 'when current_user is an ApiKey' do
    let(:current_user) { create(:api_key) }
    subject { SearchResultPolicy.new(current_user) }

    %i(search?).each do |method|
      it "does not allow #{method}" do
        expect(subject.public_send(method)).to be(false)
      end
    end
  end
end
