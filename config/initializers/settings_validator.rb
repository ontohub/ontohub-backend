# frozen_string_literal: true

# Because of the order in which the initializers are loaded, this file needs to
# contain two classes: SettingsValidator and SettingsPresenceValidator.

# Validates the settings and exits if they are invalid.
class SettingsValidator
  ERROR_MESSAGE_HEADER = <<MSG
The settings are invalid! Can not start the application.
Please set valid values in config/settings[.local].yml
or config/settings/#{Rails.env}[.local].yml
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

    if @error_messages.any?
      print_errors
      shutdown
    end
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
  end

  def prepare_error_messages
    @errors.each do |key, (message, value)|
      @error_messages << "#{key} #{message}\n\tSet value:\n\t#{value}"
    end
  end

  # :nocov:
  def print_errors
    $stderr.puts(ERROR_MESSAGE_HEADER)
    $stderr.puts(@error_messages.join("\n\n"))
  end
  # :nocov:

  # Checker methods
  def check_server_url
    key = 'server_url'
    value = @settings.server_url
    validate_type_string(key, value)
    return if @errors['server_url']

    uri = URI(@settings.server_url)

    allowed_schemes = %w(http https)
    if !allowed_schemes.include?(uri.scheme)
      add_error(key, ['has an invalid scheme (only http, https) are allowed)',
                       value])
    end
    add_error(key, ['is not an absolute URL', value]) unless uri.absolute?
    add_error(key, ['must not have a path', uri.path]) unless uri.path.empty?
    unless uri.query.nil?
      add_error(key, ['must not have a query string', uri.query])
    end
    unless uri.fragment.nil?
      add_error(key, ['must not have a fragment', uri.fragment])
    end
    unless uri.userinfo.nil?
      add_error(key, ['must not have userinfo', uri.userinfo])
    end
  end

  def check_jwt_expiration_hours
    validate_type_numeric('jwt.expiration_hours', @settings.jwt.expiration_hours)
  end

  def check_data_path
    validate_directory('data_directory', @settings.data_directory)
  end

  # Validator methods
  def validate_directory(key, value)
    add_error(key, ["is not a directory", value]) unless File.directory?(value)
  end

  def validate_presence(key, value)
    add_error(key, ['is not set', value.inspect]) if value.nil?
  end

  def validate_type_numeric(key, value)
    unless value.is_a?(Numeric)
      add_error(key, ['is not a number', value.inspect])
    end
  end

  def validate_type_string(key, value)
    unless value.is_a?(String)
      add_error(key, ['is not a string', value.inspect])
    end
  end

  # Helper methods
  def add_error(key, error)
    errors = @errors[key] || []
    errors << error
    @errors[key] = errors
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
      'data_directory' => @settings.data_directory
    }.each do |key, value|
      validate_presence(key, value)
    end
  end
end
