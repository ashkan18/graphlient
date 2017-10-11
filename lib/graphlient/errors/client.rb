module Graphlient
  module Errors
    class Client < StandardError
      attr_reader :root_error
      def initialize(message, root_error = nil)
        super(message)
        @root_error = root_error
      end
    end
  end
end
