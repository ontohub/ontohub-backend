# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchResultPolicy do
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
