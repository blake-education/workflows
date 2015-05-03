module Workflows
  class ErrorValue < Struct.new(:value)
  end

  module Error
    extend self

    def error?(e)
      ErrorValue === e
    end

    def sucess?(e)
      ! error?(e)
    end

    def to_error(e)
      case e
      when ErrorVal
        e
      else
        ErrorVal.new(e)
      end
    end

    def compose_with_error_handling(*fns)
      fns.flatten.inject do |composed, fn|
        ->(*args) {
          last_return = composed.call(*args)
          if Workflows::Error.error?(last_return)
            last_return
          else
            fn.call
          end
        }
      end
    end
  end
end
