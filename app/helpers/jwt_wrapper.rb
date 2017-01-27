# frozen_string_literal: true

# JWT Wrapper for generating keys
module JWTWrapper
  def self.generate_private_key
    key = OpenSSL::PKey::EC.new('prime256v1')
    key.generate_key
  end
  PRIVATE_KEY = generate_private_key

  def self.generate_public_key
    key = OpenSSL::PKey::EC.new(PRIVATE_KEY)
    key.private_key = nil
    key
  end
  PUBLIC_KEY = generate_public_key

  extend module_function

  def encode(payload, expiration = nil)
    expiration ||= Settings.jwt.expiration_hours

    payload = payload.dup
    payload['exp'] = expiration.to_i.hours.from_now.to_i

    JWT.encode(payload, PRIVATE_KEY, 'ES256')
  end

  def decode(token)
    decoded_token = JWT.decode(token, PUBLIC_KEY, true, algorithm: 'ES256')
    decoded_token.first
  rescue JWT::DecodeError
    nil
  end

  def keys
    ecdsa_key = OpenSSL::PKey::EC.new('prime256v1')
    ecdsa_key.generate_key
    ecdsa_public = OpenSSL::PKey::EC.new(ecdsa_key)
    ecdsa_public.private_key = nil
    {private: ecdsa_key, public: ecdsa_public}
  end
end
