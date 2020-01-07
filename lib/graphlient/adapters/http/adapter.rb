module Graphlient
  module Adapters
    module HTTP
      class Adapter
        attr_accessor :url, :options

        def initialize(url, options = {}, &_block)
          @url = url
          @options = options.dup if options
          yield self if block_given?
        end

        def headers
          options[:headers] if options
        end

        def http_options
          return {} unless options

          options[:http_options] || {}
        end

        def execute(*)
          raise NotImplementedError
        end

        private

        def configure_http_options(client_options)
          http_options.each do |k, v|
            begin
              client_options.send("#{k}=", v)
            rescue NoMethodError => e
              raise Graphlient::Errors::HttpOptionsError, e.message
            end
          end
        end
      end
    end
  end
end
