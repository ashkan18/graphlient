module Graphlient
  module Errors
    class Error < StandardError
      attr_reader :inner_exception
      def initialize(message, inner_exception = nil)
        super(message)

        @inner_exception = inner_exception
      end
    end
  end
end
