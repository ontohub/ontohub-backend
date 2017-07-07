# frozen_string_literal: true

RSpec.configure do |config|
  # Stub Device's internals that require a request object.
  config.before(:each, :stub_abstract_devise_mutation) do
    allow_any_instance_of(Mutations::AbstractDeviseMutation).
      to receive(:setup_devise)

    allow_any_instance_of(Mutations::AbstractDeviseMutation).
      to receive(:sign_in)

    allow_any_instance_of(Mutations::AbstractDeviseMutation).
      to receive_message_chain(:session, :empty?)

    allow_any_instance_of(Mutations::AbstractDeviseMutation).
      to receive_message_chain(:session, :keys, :grep, :each)

    request = OpenStruct.new(params: {})
    allow_any_instance_of(Mutations::AbstractDeviseMutation).
      to receive(:request).and_return(request)
  end
end
