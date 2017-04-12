# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TreeEntry do
  subject { create :tree_entry }

  context 'attributes' do
    %i(name path type).each do |attribute|
      it "contain a getter for #{attribute}" do
        expect(subject).to respond_to(attribute)
      end

      it "contain a setter for #{attribute}" do
        expect(subject).to respond_to("#{attribute}=")
      end
    end
  end
end
