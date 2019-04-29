module Graphlient
  module Errors
    class ConnectionFailedError < ServerError
      def initialize(inner_exception)
        @inner_exception = inner_exception
        @response = inner_exception.wrapped_exception
      end
    end
  end
end
