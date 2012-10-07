module Reaction

  module Mixins

    # Provides convenience functions for logging.
    # @example Log messages with +:debug+ and +:error+ levels respectively.
    #   class X
    #     include Mixins::Logging
    #
    #     # lazy evaluation
    #     debug { "This is a " + potentially + " expensive operation" }
    #
    #     # eager evaluation
    #     error("This should be cheap.")
    #
    #   end
    module Logging

      # Available log levels and their colors, each with a corresponding method.
      LOG_LEVELS = {
        :fatal => "\e[31m",
        :error => "\e[35m",
        :warn => "\e[33m",
        :info => "\e[32m",
        :debug => "\e[36m"
      }

      # Maps environment (production/development/test) to log levels.
      LOG_CONCERNS = {'production' => Logger::ERROR, 'development' => Logger::DEBUG}

      class << self

        # Initializes and returns a new logger.
        # @return [Logger]
        def new_logger
          log = Logger.new(STDOUT)
          log.level = LOG_CONCERNS[ENV['RACK_ENV']] || Logger::INFO
          log.formatter = new_formatter
          log
        end

        private

        # Initializes and returns a new formatter.
        def new_formatter
          formatter = Logger::Formatter.new
          proc { |severity, datetime, progname, msg|
            format = "#{LOG_LEVELS[severity.downcase.to_sym]}%p\e[0m"
            formatter.call(severity, datetime, progname, format % msg)
          }
        end

      end # self

      LOG_LEVELS.keys.each do |level|
        define_method(level) { |*args, &block|
          next unless Reaction.logger
          Reaction.logger.send(level, *args, &block)
        }
      end

    end # Logging

  end # Mixins

end # Reaction
