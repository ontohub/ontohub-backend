# frozen_string_literal: true

# Use the JSON API adapter
ActiveModelSerializers.config.adapter = :json_api

# Enable automatic serializer lookup
ActiveModelSerializers.config.serializer_lookup_enabled = true

# Do not transform parameter keys
ActiveModelSerializers.config.key_transform = :unaltered

# Use the plural form of the "type" values in the output
ActiveModelSerializers.config.jsonapi_resource_type = :plural

# Include a "jsonapi" toplevel object in the output
ActiveModelSerializers.config.jsonapi_include_toplevel_object = true

# Include this JSON API version in the output
ActiveModelSerializers.config.jsonapi_version = '1.0'

# Include this toplevel meta data in the output
ActiveModelSerializers.config.jsonapi_toplevel_meta = {}

# Register a JSON API renderer in order to properly handle JSON API responses
ActiveSupport.on_load(:action_controller) do
  require 'active_model_serializers/register_jsonapi_renderer'
end
