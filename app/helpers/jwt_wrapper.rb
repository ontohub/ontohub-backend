# frozen_string_literal: true

module JWTWrapper
  extend self

  def encode(payload, expiration = nil)
    expiration ||= Settings.jwt.expiration_hours

    payload = payload.dup
    payload['exp'] = expiration.to_i.hours.from_now.to_i

    JWT.encode payload, Rails.application.secrets.jwt_secret
  end

  def decode(token)
    begin
      decoded_token = JWT.decode token, Rails.application.secrets.jwt_secret

      decoded_token.first
    rescue
      nil
    end
  end
end
