module RuboCop
  module Cop
    module Naming
      class MethodNameGetPrefix < Base
        extend AutoCorrector

        MSG_GET = 'Avoid using `get_` prefix for methods with arguments. ' \
                  'Consider using `%<method_name>s_for` or `find_%<method_name>s` instead.'

        MSG_SET = 'Avoid using `set_` prefix for methods with arguments. ' \
                  'Consider using `%<method_name>s=` instead.'

        MSG_SET_API = 'Avoid using `set_` prefix for methods with arguments. ' \
                       'Consider using `%<suggestions>s` instead.'

        # Patterns that indicate HTTP GET requests (methods that should be excluded)
        HTTP_GET_PATTERNS = [
          /\.get\(/,                    # connection.get, HTTP.get, etc.
          /connection\.get/,            # Faraday connection.get
          /HTTP\.get/,                  # Net::HTTP.get
          /RestClient\.get/,            # RestClient.get
          /Faraday\.get/,               # Direct Faraday.get
          /Net::HTTP\.get/,             # Net::HTTP.get
          /\.get\s*\(/,                 # Any .get( call
          /Net::HTTP::Get\.new/,        # Net::HTTP::Get.new (like in affirm.rb)
          /Net::HTTP::Get/,             # Net::HTTP::Get class reference
          /http\.request/,              # http.request(request) where request is GET
          /https\.request/,             # https.request(request) where request is GET
          /Net::HTTP\.new/              # Net::HTTP.new (indicates HTTP client usage)
        ].freeze

        # Patterns for standalone get() calls that are likely HTTP GET wrappers
        # (only checked in API client files)
        HTTP_GET_WRAPPER_PATTERNS = [
          /\bget\s*\(/                  # get(...) method call
        ].freeze

        # File path patterns that indicate API clients/controllers
        API_FILE_PATTERNS = [
          /client/i,                    # *client*.rb
          /api_client/i,                 # *api_client*.rb
          /controller/i,                # *controller*.rb
          /\/api\//,                    # files in /api/ directory
          /\/clients\//                 # files in /clients/ directory
        ].freeze

        def on_def(node)
          method_name = node.method_name.to_s

          if method_name.start_with?('get_')
            handle_get_prefix(node)
          elsif method_name.start_with?('set_')
            handle_set_prefix(node)
          end
        end

        def handle_get_prefix(node)
          return if node.arguments.empty? # Let Naming/AccessorMethodName handle these

          # Skip if method makes HTTP GET requests
          return if makes_http_get_request?(node)

          # Skip if file path suggests it's an API client/controller
          # AND method calls get() which is likely an HTTP GET wrapper
          return if api_file?(node) && calls_get_method?(node)

          method_name_without_prefix = node.method_name.to_s.sub(/^get_/, '')
          suggested_name = "#{method_name_without_prefix}_for"

          add_offense(node, message: format(MSG_GET, method_name: method_name_without_prefix)) do |corrector|
            corrector.replace(node.loc.name, suggested_name)
          end
        end

        def handle_set_prefix(node)
          return if node.arguments.empty? # Let Naming/AccessorMethodName handle these

          method_name_without_prefix = node.method_name.to_s.sub(/^set_/, '')

          # For API files, suggest create_, put_, or update_ prefixes
          if api_file?(node)
            suggested_names = [
              "create_#{method_name_without_prefix}",
              "put_#{method_name_without_prefix}",
              "update_#{method_name_without_prefix}"
            ]
            msg = format(MSG_SET_API,
                         suggestions: suggested_names.join('`, `'))
          else
            # For regular methods, use the = method syntax
            msg = format(MSG_SET, method_name: method_name_without_prefix)
          end

          add_offense(node, message: msg) do |corrector|
            if api_file?(node)
              # Default to create_ prefix for API files
              corrector.replace(node.loc.name, "create_#{method_name_without_prefix}")
            else
              corrector.replace(node.loc.name, "#{method_name_without_prefix}=")
            end
          end
        end

        private

        def makes_http_get_request?(node)
          source = node.source
          HTTP_GET_PATTERNS.any? { |pattern| source.match?(pattern) }
        end

        def api_file?(_node)
          file_path = processed_source.file_path
          API_FILE_PATTERNS.any? { |pattern| file_path.match?(pattern) }
        end

        def calls_get_method?(node)
          source = node.source
          HTTP_GET_WRAPPER_PATTERNS.any? { |pattern| source.match?(pattern) }
        end
      end
    end
  end
end
