module Graphlient
  module Errors
    class FaradayServerError < ServerError
      def initialize(inner_exception)
        super(inner_exception.message, inner_exception)
        @inner_exception = inner_exception
        @response = inner_exception.response.try(:[],:body)
        @status_code = inner_exception.response.try(:[],:status)
      end
    end
  end
end
