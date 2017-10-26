module Graphlient
  module Errors
    class GraphQL < Error
      attr_reader :response

      def initialize(response)
        @response = response
        super 'the server responded with a GraphQL error'
      end

      def errors
        response.errors
      end

      def to_s
        errors.details.map do |key, details|
          details = create_details(details).join("\n")
          [key == 'data' ? nil : key, details].compact.join(': ')
        end.join("\n")
      end

      private

      def create_details(details)
        details.map { |detail| create_detail(detail) }
      end

      def create_detail(detail)
        message = detail['message']
        [message, create_problems(detail['problems']).compact.join("\n  ")].join("\n  ")
      end

      def create_problems(problems)
        problems.map { |problem| create_problem(problem) }
      end

      def create_problem(problem)
        paths = problem['path'].join(', ')
        explanation = problem['explanation']
        [paths, explanation].join(': ')
      end
    end
  end
end
