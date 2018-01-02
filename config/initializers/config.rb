# frozen_string_literal: true

Dir.glob('app/workers/*.rb').each do |file|
  require_relative Rails.root.join(file).to_s
end

Config.setup do |c|
  # Name of the constant exposing loaded settings
  c.const_name = 'Settings'

  # Ability to remove elements of the array set in earlier loaded settings file.
  # For example value: '--'.
  #
  # config.knockout_prefix = nil

  # Overwrite arrays found in previously loaded settings file. When set to
  # `false`, arrays will be merged.
  #
  c.overwrite_arrays = true

  # Load environment variables from the `ENV` object and override any settings
  # defined in files.
  #
  # config.use_env = false

  # Define ENV variable prefix deciding which variables to load into config.
  #
  # config.env_prefix = 'Settings'

  # What string to use as level separator for settings loaded from ENV
  # variables. Default value of '.' works well with Heroku, but you might want
  # to change it for example for '__' to easy override settings from command
  # line, where using dots in variable names might not be allowed (eg. Bash).
  #
  # config.env_separator = '.'

  # Ability to process variables names:
  #   * nil  - no change
  #   * :downcase - convert to lower case
  #
  # config.env_converter = :downcase

  # Parse numeric values as integers instead of strings.
  #
  c.env_parse_values = true

  c.schema do
    configure do
      config.messages_file = Rails.root.join("config/initializers/settings_validation_errors.yml")

      def scheme?(list, value)
        Array(list).include?(URI(value).scheme)
      end

      def absolute?(value)
        URI(value).absolute?
      end

      def has_no_path?(value)
        URI(value).path.empty?
      end

      def has_no_query?(value)
        URI(value).query.nil?
      end

      def has_no_fragment?(value)
        URI(value).fragment.nil?
      end

      def has_no_userinfo?(value)
        URI(value).userinfo.nil?
      end

      def is_directory?(value)
        File.directory?(value)
      end

      def is_worker_class?(value)
        klass = value.constantize
        klass.instance_methods.include?(:work)
      rescue NameError
        false
      end
    end

    required(:server_url).filled(:str?,
                                 :absolute?,
                                 :has_no_path?,
                                 :has_no_query?,
                                 :has_no_fragment?,
                                 :has_no_userinfo?,
                                 scheme?: %w(http https))

    required(:jwt).schema do
      required(:expiration_hours).filled { int? | float? }
    end

    required(:data_directory).filled(:is_directory?)

    required(:sneakers).each do
      schema do
        required(:workers).filled(:int?)
        required(:classes).filled do
          (str? > is_worker_class?) | array? { each { is_worker_class? } }
        end
      end
    end
  end
end
