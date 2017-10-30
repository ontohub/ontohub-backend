# frozen_string_literal: true

# Because of the order in which the initializers are loaded, this file needs to
# contain two classes: SettingsValidator and SettingsPresenceValidator.

# Validates the settings and exits if they are invalid.
# rubocop:disable ClassLength
class SettingsValidator
  # rubocop:enable ClassLength
  ERROR_MESSAGE_HEADER = <<~MSG
    The settings are invalid! Can not start the application.
    Please set valid values in config/settings[.local].yml or
    config/settings/#{Rails.env}[.local].yml
  MSG

  attr_reader :errors, :settings

  def initialize(settings)
    @settings = settings
  end

  def call
    @errors = {}
    @error_messages = []

    run_checks
    prepare_error_messages

    return unless @error_messages.any?

    print_errors
    shutdown
  end

  protected

  # :nocov:
  def shutdown
    exit
  end
  # :nocov:

  def run_checks
    check_server_url
    check_jwt_expiration_hours
    check_data_path
    check_sneakers_config
  end

  def prepare_error_messages
    @errors.each do |key, (message, value)|
      @error_messages << "#{key} #{message}\n\tSet value:\n\t#{value}"
    end
  end

  # :nocov:
  def print_errors
    warn(ERROR_MESSAGE_HEADER)
    warn(@error_messages.join("\n\n"))
  end
  # :nocov:

  # Checker methods
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
  def check_server_url
    # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
    key = 'server_url'
    value = @settings.server_url
    validate_type_string(key, value)
    return if @errors['server_url']

    uri = URI(@settings.server_url)

    allowed_schemes = %w(http https)

    # rubocop:disable Metrics/LineLength
    unless allowed_schemes.include?(uri.scheme)
      add_error(key, ['has an invalid scheme (only http, https) are allowed)', value])
    end
    add_error(key, ['is not an absolute URL', value]) unless uri.absolute?
    add_error(key, ['must not have a path', uri.path]) unless uri.path.empty?
    add_error(key, ['must not have a query string', uri.query]) unless uri.query.nil?
    add_error(key, ['must not have a fragment', uri.fragment]) unless uri.fragment.nil?
    add_error(key, ['must not have userinfo', uri.userinfo]) unless uri.userinfo.nil?
    # rubocop:enable Metrics/LineLength
  end

  def check_jwt_expiration_hours
    validate_type_numeric('jwt.expiration_hours',
                          @settings.jwt.expiration_hours)
  end

  def check_data_path
    validate_directory('data_directory', @settings.data_directory)
  end

  def check_sneakers_config
    return unless validate_type_array('sneakers', @settings.sneakers)
    @settings.sneakers.map.with_index do |group, idx|
      validate_type_numeric("sneakers[#{idx}].workers", group.workers)
      validate_type_array_or_string("sneakers[#{idx}].classes", group.classes)

      Array(group.classes).map.with_index do |klass, klass_idx|
        validate_worker_class("sneakers[#{idx}].classes[#{klass_idx}]", klass)
      end
    end
  end

  # Validator methods
  def validate_directory(key, value)
    return true if File.directory?(value)
    add_error(key, ['is not a directory', value])
  end

  def validate_presence(key, value)
    return true unless value.nil?
    add_error(key, ['is not set', value.inspect])
  end

  def validate_type_numeric(key, value)
    return true if value.is_a?(Numeric)
    add_error(key, ['is not a number', value.inspect])
  end

  def validate_type_string(key, value)
    return true if value.is_a?(String)
    add_error(key, ['is not a string', value.inspect])
  end

  def validate_type_array(key, value)
    return true if value.is_a?(Array)
    add_error(key, ['is not an array', value.inspect])
  end

  def validate_type_array_or_string(key, value)
    return true if value.is_a?(Array) || value.is_a?(String)
    add_error(key, ['is not an array or a string', value.inspect])
  end

  def validate_worker_class(key, value)
    worker_class = value.constantize
    return true if worker_class.instance_methods.include?(:work)
  rescue NameError
    add_error(key, ['is not a valid worker class', value.inspect])
  end

  # Helper methods
  def add_error(key, error)
    errors = @errors[key] || []
    errors << error
    @errors[key] = errors
    false
  end
end

# Validates the presence of settings and exits if they are not set.
class SettingsPresenceValidator < SettingsValidator
  protected

  def run_checks
    {
      'server_url' => @settings.server_url,
      'jwt' => @settings.jwt,
      'jwt.expiration_hours' => @settings.jwt.expiration_hours,
      'data_directory' => @settings.data_directory,
      'sneakers' => @settings.sneakers,
    }.each do |key, value|
      validate_presence(key, value)
    end
  end
end
