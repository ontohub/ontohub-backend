# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchPolicy do
  context 'search?' do
    context 'signed in' do
      let(:current_user) { create :user }
      subject { SearchPolicy.new(current_user) }

      it 'should allow to search' do
        expect(subject.search?).to be(true)
      end
    end

    context 'signed in as admin' do
      let(:current_user) { create :user, :admin }
      subject { SearchPolicy.new(current_user) }

      it 'should allow to search' do
        expect(subject.search?).to be(true)
      end
    end

    context 'not signed in' do
      let(:current_user) { nil }
      subject { SearchPolicy.new(current_user) }

      it 'should allow to search' do
        expect(subject.search?).to be(true)
      end
    end
  end
end
