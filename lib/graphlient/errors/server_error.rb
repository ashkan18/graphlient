module Graphlient
  module Errors
    class ServerError < Error
      attr_reader :inner_exception, :status_code, :response

      def initialize(message, inner_exception)
        super(message)
        @inner_exception = inner_exception
      end
    end
  end
end
