module Graphlient
  module Extensions
    module Query
      def method_missing(method_name, *args, &block)
        Graphlient::Query.new do
          send(method_name, *args, &block)
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        super
      end
    end
  end
end
