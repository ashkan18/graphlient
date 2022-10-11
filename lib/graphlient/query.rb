module Graphlient
  class Query
    SCALAR_TYPES = {
      int: 'Int',
      float: 'Float',
      string: 'String',
      boolean: 'Boolean'
    }.freeze

    ROOT_NODES = %w[query mutation subscription].freeze

    FRAGMENT_DEFITION = /___(?<const>[A-Z][a-zA-Z0-9_]*(__[A-Z][a-zA-Z0-9_]*)*)/

    attr_accessor :query_str

    def initialize(&block)
      @indents = 0
      @query_str = ''
      @variables = []
      evaluate(&block)
    end

    def method_missing(method_name, *args, &block)
      append_node(method_name, args, &block)
    end

    ROOT_NODES.each do |root_node|
      define_method(root_node) do |*args, &block|
        @variables = args.first unless args.empty?
        append_node(root_node, args, arg_processor: ->(k, v) { "$#{k}: #{variable_string(v)}" }, &block)
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      super
    end

    def to_s
      query_str.strip
    end

    private

    def evaluate(&block)
      @last_block = block || self
      (@context ||= {})[@last_block] ||= @last_block.binding
      instance_eval(&block)
    end

    def resolve_fragment_constant(value)
      return nil unless (match = value.to_s.match(FRAGMENT_DEFITION))
      raw_const = match[:const].gsub('__', '::')
      @context[@last_block].eval(raw_const).tap do |const|
        msg = "Expected constant #{raw_const} to be GraphQL::Client::FragmentDefinition. Given #{const.class}"
        raise Graphlient::Errors::Error, msg unless const.is_a? GraphQL::Client::FragmentDefinition
      end
    end

    def append_node(node, args, arg_processor: nil, &block)
      node = "...#{resolve_fragment_constant(node)}".to_sym if node.to_s.start_with?('___')

      # add field
      @query_str << "\n#{indent}#{node}"
      # add filter
      hash_arguments = hash_arg(args)
      @query_str << "(#{args_str(hash_arguments, arg_processor: arg_processor)})" if hash_arguments

      if block_given?
        @indents += 1
        @query_str << '{'
        evaluate(&block)
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

    def argument_string(key, val)
      "#{key}: #{argument_value_string(val)}"
    end

    def variable_string(val)
      case val
      when :id, :id!
        val.to_s.upcase
      when ->(v) { SCALAR_TYPES.key?(v.to_s.delete('!').to_sym) }
        # scalar types
        val.to_s.camelize
      when Array
        "[#{variable_string(val.first)}]"
      else
        val.to_s
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
        @variables.key?(value) ? "$#{value}" : value.to_s.camelize(:lower)
      else
        value
      end
    end
  end
end
