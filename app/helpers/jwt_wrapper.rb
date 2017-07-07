# frozen_string_literal: true

# JWT Wrapper for generating keys
module JWTWrapper
  extend module_function

  # :nocov:
  # This is only used before the application starts to set up the keys
  def generate_private_key
    key = OpenSSL::PKey::EC.new('prime256v1')
    key.generate_key
  end

  def generate_public_key(private_key)
    key = OpenSSL::PKey::EC.new(private_key)
    key.private_key = nil
    key
  end

  def generate_key_pair
    private_key = generate_private_key
    public_key = generate_public_key(private_key)
    {public: public_key, private: private_key}
  end
  # :nocov:

  PRIVATE_KEY = OpenSSL::PKey::EC.new(Rails.application.secrets.jwt[:private])
  PUBLIC_KEY = OpenSSL::PKey::EC.new(Rails.application.secrets.jwt[:public])

  def encode(payload, expiration = nil)
    expiration ||= Settings.jwt.expiration_hours

    payload['exp'] = expiration.to_i.hours.from_now.to_i

    JWT.encode(payload, PRIVATE_KEY, 'ES256')
  end

  def decode(token)
    decoded_token = JWT.decode(token, PUBLIC_KEY, true, algorithm: 'ES256')
    decoded_token.first
  rescue JWT::DecodeError
    nil
  end

  def generate_token(user)
    payload = {user_id: user.to_param}
    AuthenticationToken.new(token: JWTWrapper.encode(payload))
  end
end
