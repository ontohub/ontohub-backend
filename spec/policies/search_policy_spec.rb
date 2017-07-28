# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchPolicy do
  let(:user) { create :user }
  let(:admin) { create :user, :admin }

  context 'search?' do
    context 'signed in' do
      subject { SearchPolicy.new(user) }

      it 'allows to search' do
        expect(subject.search?).to be(true)
      end
    end

    context 'signed in as admin' do
      subject { SearchPolicy.new(admin) }

      it 'allows to search' do
        expect(subject.search?).to be(true)
      end
    end

    context 'not signed in' do
      subject { SearchPolicy.new(nil) }

      it 'allows to search' do
        expect(subject.search?).to be(true)
      end
    end
  end
end
