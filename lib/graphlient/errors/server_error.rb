module Graphlient
  module Errors
    class ServerError < Error
      attr_reader :status_code, :response
    end
  end
end
