module Graphlient
  module Errors
    class ExecutionError < Error
      attr_reader :response

      def initialize(response)
        super('the server responded with a GraphQL execution error')
        @response = response
      end

      def errors
        response.data.errors
      end

      def to_s
        errors.details.map do |key, details|
          details = create_details(details).join("\n")
          [key, details].compact.join(': ')
        end.join("\n")
      end

      private

      def create_details(details)
        details.map { |detail| detail['message'] }
      end
    end
  end
end
