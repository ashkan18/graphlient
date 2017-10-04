module Graphlient
  module Extensions
    module Query
      def method_missing(m, *args, &block)
        Graphlient::Query.new do
          send(m, *args, &block)
        end
      end

      def respond_to_missing?(m, include_private = false)
        super
      end
    end
  end
end
