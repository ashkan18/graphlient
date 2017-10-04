
module Graphlient
  module Config
    extend self

    def reset; end

    reset
  end

  class << self
    def configure
      yield(Config) if block_given?
      Config
    end

    def config
      Config
    end
  end
end
