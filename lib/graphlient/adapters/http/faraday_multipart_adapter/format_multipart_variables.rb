require 'faraday'
require 'mime/types'
require 'graphlient/errors'

module Graphlient
  module Adapters
    module HTTP
      class FaradayMultipartAdapter
        class NoMimeTypeException < Graphlient::Errors::Error; end
        # Converts deeply nested File instances to Faraday::UploadIO
        class FormatMultipartVariables
          def initialize(variables)
            @variables = variables
          end

          def call
            deep_transform_values(variables) do |variable|
              variable_value(variable)
            end
          end

          private

          attr_reader :variables

          def deep_transform_values(hash, &block)
            return hash unless hash.is_a?(Hash)

            hash.transform_values do |val|
              if val.is_a?(Hash)
                deep_transform_values(val, &block)
              else
                yield(val)
              end
            end
          end

          def variable_value(variable)
            if variable.is_a?(Array)
              variable.map { |it| variable_value(it) }
            elsif variable.is_a?(Hash)
              variable.transform_values { |it| variable_value(it) }
            elsif variable.is_a?(File)
              file_variable_value(variable)
            else
              variable
            end
          end

          def file_variable_value(file)
            content_type = MIME::Types.type_for(file.path).first
            return Faraday::UploadIO.new(file.path, content_type) if content_type

            raise NoMimeTypeException, "Unable to determine mime type for #{file.path}"
          end
        end
      end
    end
  end
end
