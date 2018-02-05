# frozen_string_literal: true

raw_key = 'FqeNBVtaNi3D5Bdsgk6_DDCbMqATpsEYxBtx3iZmsfb7y21rHqEXYnXRb3AasEZY'
encoded_key = HetsApiKey.digest(Rails.application.secrets.api_key_base, raw_key)
HetsApiKey.create(key: encoded_key, comment: 'seeded key')

raw_key = '8b2J6uUJgAiXxTEEJ4aSWc3npmGGUrKNW9LxJjMK1UxcKXnP8K3y9MATB6MEPRQP'
encoded_key =
  GitShellApiKey.digest(Rails.application.secrets.api_key_base, raw_key)
GitShellApiKey.create(key: encoded_key, comment: 'seeded key')
