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
      query_str.strip
    end

    private

    def append(query_field, args, &block)
      # add field
      @query_str << "\n#{indent}#{query_field}"
      # add filter
      @query_str << "(#{get_args_str(args)})" if find_hash_arg(args)

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
      hash_args_str(find_hash_arg(args))
    end

    def find_hash_arg(args)
      args.detect { |arg| arg.is_a? Hash }
    end

    def hash_args_str(hash)
      hash.map { |k, v| "#{k}: #{get_arg_value_str(v)}" }.join(', ')
    end

    def get_arg_value_str(value)
      case value
      when String
        "\"#{value}\""
      when Numeric
        value.to_s
      when Array
        "[#{value.map { |v| get_arg_value_str(v) }.join(', ')}]"
      when Hash
        "{ #{hash_args_str(value)} }"
      else
        value
      end
    end
  end
end
