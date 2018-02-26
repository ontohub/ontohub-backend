# frozen_string_literal: true

host = Settings.elasticsearch.host
port = Settings.elasticsearch.port
Chewy.settings = {host: "#{host}:#{port}",
                  prefix: Settings.elasticsearch.prefix}
