# frozen_string_literal: true

# Helper module for signing up a user.
module AccountMethods
  include ::Recaptcha::Verify

  DISABLE_CAPTCHA = ENV['DISABLE_CAPTCHA'] == 'true'

  # Build a devise resource passing in the session. Useful to move
  # temporary session data to the newly created user.
  # This is overwriting the original method.
  # rubocop:disable Metrics/AbcSize
  def build_resource(hash = nil)
    # rubocop:enable Metrics/AbcSize
    self.resource = User.new_with_session(hash || {}, session)
    resource.role ||= 'user'
    resource.valid?
    return if DISABLE_CAPTCHA || captcha_ok?
    # +captcha_ok?+ is always +true+ in the test environment
    # :nocov:
    resource.errors.replace(resource.errors.slice(:captcha))
    raise Sequel::ValidationFailed, resource
    # :nocov:
  end

  def captcha_ok?
    # +verify_recaptcha+ is always +true+ in the test environment
    verify_recaptcha(model: resource,
                     attribute: :captcha,
                     response: captcha)
  end
end
