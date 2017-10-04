module Graphlient
  module Errors
    class HTTP < Error
      attr_reader :response

      def initialize(message, response = nil)
        @response = response
        super message
      end
    end
  end
end
