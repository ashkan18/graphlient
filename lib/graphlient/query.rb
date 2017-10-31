module Graphlient
  class Query
    SCALAR_TYPES = {
      int: 'Int',
      float: 'Float',
      string: 'String',
      boolean: 'Boolean'
    }.freeze

    ROOT_NODES = %w(query mutation subscription).freeze

    attr_accessor :query_str

    def initialize(&block)
      @indents = 0
      @query_str = ''
      @variables = []
      instance_eval(&block)
    end

    def method_missing(m, *args, &block)
      append_node(m, args, &block)
    end

    ROOT_NODES.each do |root_node|
      define_method(root_node) do |*args, &block|
        @variables = args.first unless args.empty?
        append_node(root_node, args, arg_processor: ->(k, v) { "$#{k}: #{variable_string(v)}" }, &block)
      end
    end

    def respond_to_missing?(m, include_private = false)
      super
    end

    def to_s
      query_str.strip
    end

    private

    def append_node(node, args, arg_processor: nil, &block)
      # add field
      @query_str << "\n#{indent}#{node}"
      # add filter
      hash_arguments = hash_arg(args)
      @query_str << "(#{args_str(hash_arguments, arg_processor: arg_processor)})" if hash_arguments

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

    def hash_arg(args)
      args.detect { |arg| arg.is_a? Hash }
    end

    def args_str(hash_args, arg_processor: nil)
      hash_args.map do |k, v|
        arg_processor ? arg_processor.call(k, v) : argument_string(k, v)
      end.join(', ')
    end

    def argument_string(k, v)
      "#{k}: #{argument_value_string(v)}"
    end

    def variable_string(v)
      case v
      when :id, :id!
        v.to_s.upcase
      when ->(value) { SCALAR_TYPES.key?(value.to_s.delete('!').to_sym) }
        # scalar types
        v.to_s.camelize
      when Array
        "[#{variable_string(v.first)}]"
      else
        v.to_s
      end
    end

    def argument_value_string(value)
      case value
      when String
        "\"#{value}\""
      when Numeric
        value.to_s
      when Array
        "[#{value.map { |v| argument_value_string(v) }.join(', ')}]"
      when Hash
        "{ #{value.map { |k, v| "#{k}: #{argument_value_string(v)}" }.join(', ')} }"
      when Symbol
        @variables.keys.include?(value) ? "$#{value}" : value.to_s.camelize(:lower)
      else
        value
      end
    end
  end
end
