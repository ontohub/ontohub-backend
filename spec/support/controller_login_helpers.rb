# frozen_string_literal: true

# Helper methods for user login handling in controller specs
module ControllerLoginHelpers
  module ClassHelpers
    def create_user_and_sign_in
      before(:each) do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        user = FactoryGirl.create(:user)
        # Confirm the user. Alternatively, set a confirmed_at inside the factory.
        # Only necessary if you are using the "confirmable" module:
        # user.confirm!
        sign_in(user)
      end
    end
  end

  module InstanceHelpers
    def create_user_and_set_token_header
      user = FactoryGirl.create(:user)
      set_token_header(user)
    end

    def set_token_header(user)
      payload = {user_id: user.to_param}
      token = JWTWrapper.encode(payload)
      request.env['HTTP_AUTHORIZATION'] = "Bearer #{token}"
    end
  end
end
