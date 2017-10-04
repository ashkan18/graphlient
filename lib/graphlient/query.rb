module Graphlient
  class Query
    attr_accessor :query_str

    def initialize(&block)
      @indents = 0
      @query_str = ''
      instance_eval(&block)
    end

    def method_missing(m, *args, &block)
      append(m, args, &block)
    end

    def respond_to_missing?(m, include_private = false)
      super
    end

    def to_s
      "{ #{query_str} }"
    end

    private

    def append(query_field, args, &block)
      # add field
      @query_str << "\n#{indent}#{query_field}"
      # add filter
      @query_str << "(#{get_args_str(args)})" if args.any?

      if block_given?
        @indents += 1
        @query_str << '{'
        instance_eval(&block)
        @query_str << '}'
        @indents -= 1
      end

      @query_str << "\n#{indent}"
    end

    def indent
      '  ' * @indents
    end

    def get_args_str(args)
      args.detect { |arg| arg.is_a? Hash }.map { |k, v| "#{k}: #{v}" }.join(',')
    end
  end
end
