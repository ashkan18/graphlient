module Graphlient
  class Query
    attr_accessor :query_str

    ACTIONS = %w(query mutation subscription fragment).freeze

    def initialize(&block)
      @indents = 0
      @query_str = ''
      instance_eval(&block)
    end

    ACTIONS.each do |action|
      define_method(action.to_sym) do |name, &block|
        @query_str << "#{action} #{name.capitalize}{"
        @indents += 1
        instance_eval(&block)
        @indents -= 1
        @query_str << '}'
      end
    end

    def method_missing(m, *args, &block)
      append(m, args, &block)
    end

    def respond_to_missing?(m, include_private = false)
      super
    end

    def to_s
      query_str
    end

    private

    def append(query_field, args, &block)
      # add field
      @query_str << "\n#{indent}#{query_field}"
      # add filter
      @query_str << "(#{get_args_str(args)})" if hash_args(args)

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
      hash_args(args).map do |k, v|
        "#{k}: #{get_arg_value_str(v)}"
      end.join(', ')
    end

    def hash_args(args)
      args.detect { |arg| arg.is_a? Hash }
    end

    def get_arg_value_str(value)
      case value
      when String
        "\"#{value}\""
      when Numeric
        value.to_s
      when Array
        "[#{value.map { |v| get_arg_value_str(v) }.join(', ')}]"
      else
        value
      end
    end
  end
end
