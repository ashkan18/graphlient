module Graphlient
  module Errors
    class HttpServerError < Error
      attr_reader :status_code, :response

      def initialize(message, response)
        super(message, response)
        @status_code = response.code
        @response = response.body
      end
    end
  end
end
