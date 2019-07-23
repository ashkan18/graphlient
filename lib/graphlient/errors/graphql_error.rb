module Graphlient
  module Errors
    class GraphQLError < Error
      attr_reader :response
      def initialize(response)
        super('the server responded with a GraphQL error')
        @response = response
      end

      def errors
        @response.errors
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

      ##
      # Generates human readable error explanation from a GraphQL error message
      # It first tries `problem` attribute of the error response
      # then checks for error root level `path` and tries to generate error from that
      # and if none exist, it fallbacks to just return error message
      def create_detail(detail)
        if detail.key?('problems')
          [detail['message'], create_problems(detail['problems']).compact.join("\n  ")].join("\n  ")
        elsif detail.key?('path')
          [detail['path'].compact.join(' '), detail['message']].join(': ')
        else
          detail['message']
        end
      end

      def create_problems(problems)
        problems.map { |problem| create_problem(problem) }
      end

      def create_problem(problem)
        paths = problem.key?('path') && !problem['path'].empty? ? "#{problem['path'].join(', ')}: " : ''
        [paths, problem['explanation']].compact.join
      end
    end
  end
end
