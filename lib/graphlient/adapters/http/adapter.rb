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

        def execute(*)
          raise NotImplementedError
        end
      end
    end
  end
end
