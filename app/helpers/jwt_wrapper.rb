# frozen_string_literal: true

# JWT Wrapper for generating keys
module JWTWrapper
  extend module_function

  def generate_private_key
    key = OpenSSL::PKey::EC.new('prime256v1')
    key.generate_key
  end
  PRIVATE_KEY = generate_private_key

  def generate_public_key
    key = OpenSSL::PKey::EC.new(PRIVATE_KEY)
    key.private_key = nil
    key
  end
  PUBLIC_KEY = generate_public_key

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
end
