module Graphlient
  module Errors
    class ServerError < Error
      attr_reader :status_code
      def initialize(message, http_status, response_body)
        super(message, response_body)
        @status_code = http_status
      end
    end
  end
end
