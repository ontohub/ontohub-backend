# rubocop:disable Style/FrozenStringLiteralComment
# rubocop:disable Style/PerlBackrefs
# Rails is not yet ready for frozen string literals.

module ActionDispatch
  module Journey # :nodoc:
    class Router # :nodoc:
      class Utils # :nodoc:
        original_definition_of_normalize_path = method(:normalize_path)

        define_singleton_method(:normalize_path) do |path|
          # rubocop:disable Style/GlobalVars
          if $do_not_merge_multiple_slashes_in_request_urls
            # This is basically the same as the original method, but the
            # multiple slashes are only merged if they occur at the beginning
            # of the +path+. This must only be done *after* the routes have been
            # loaded. It is called on every request to normalize the requested
            # URL.
            # :nocov:
            path = "/#{path}"
            # This is the only changed line wrt. the original code:
            path = path.sub(%r{\A/+}, '/')
            path.sub!(%r{/+\Z}, ''.freeze)
            path.gsub!(/(%[a-f0-9]{2})/) { $1.upcase }
            path = '/' if path == ''.freeze
            path
            # :nocov:
          else
            # Normalizes URI path.
            #
            # Strips off trailing slash and ensures there is a leading slash.
            # Also converts downcase url encoded string to uppercase.
            #
            #   normalize_path("/foo")  # => "/foo"
            #   normalize_path("/foo/") # => "/foo"
            #   normalize_path("foo")   # => "/foo"
            #   normalize_path("")      # => "/"
            #   normalize_path("/%ab")  # => "/%AB"
            original_definition_of_normalize_path.call(path)
          end
        end
      end
    end
  end
end
