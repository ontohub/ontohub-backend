# frozen_string_literal: true

raw_key = 'FqeNBVtaNi3D5Bdsgk6_DDCbMqATpsEYxBtx3iZmsfb7y21rHqEXYnXRb3AasEZY'
encoded_key = ApiKey.digest(Rails.application.secrets.api_key_base, raw_key)
ApiKey.create(key: encoded_key, comment: 'seeded key')
