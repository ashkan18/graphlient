module Graphlient
  module Errors
    class HttpServerError < Error
      attr_reader :inner_exception, :status_code, :response

      def initialize(response)
        super(message, response)
        @status_code = response.code
        @response = response.body
      end
    end
  end
end
