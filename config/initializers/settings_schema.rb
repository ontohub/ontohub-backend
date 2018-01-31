# frozen_string_literal: true

Dir.glob('app/workers/*.rb').sort.each do |file|
  require_relative Rails.root.join(file).to_s
end

# The Schema class to validate the Settings against
class SettingsSchema < Dry::Validation::Schema
  configure do |config|
    config.messages_file = Rails.root.join(
      'config/initializers/settings_validation_errors.yml'
    )
  end

  def uri_has_scheme?(list, value)
    Array(list).include?(URI(value).scheme)
  end

  def uri_is_absolute?(value)
    URI(value).absolute?
  end

  def uri_has_no_path?(value)
    URI(value).path.empty?
  end

  def uri_has_no_query?(value)
    URI(value).query.nil?
  end

  def uri_has_no_fragment?(value)
    URI(value).fragment.nil?
  end

  def uri_has_no_userinfo?(value)
    URI(value).userinfo.nil?
  end

  def directory?(value)
    File.directory?(value)
  end

  def create_directory?(dir)
    !!FileUtils.mkdir_p(dir) unless File.exist?(dir)
  end

  def worker_class?(value)
    klass = value.constantize
    klass.instance_methods.include?(:work)
  rescue NameError
    false
  end

  def worker_class_or_list_of_worker_classes?(value)
    value.is_a?(String) && worker_class?(value) ||
      value.is_a?(Array) && value.all? do |v|
        v.is_a?(String) && worker_class?(v)
      end
  end

  define! do
    required(:server_url).filled(:str?,
                                  :uri_is_absolute?,
                                  :uri_has_no_path?,
                                  :uri_has_no_query?,
                                  :uri_has_no_fragment?,
                                  :uri_has_no_userinfo?,
                                  uri_has_scheme?: %w(http https))

    required(:jwt).schema do
      required(:expiration_hours).filled { int? | float? }
    end

    required(:data_directory).filled do
      directory? | create_directory?
    end

    required(:sneakers).each do
      schema do
        required(:workers).filled(:int?)
        required(:classes).filled(:worker_class_or_list_of_worker_classes?)
      end
    end
  end
end
