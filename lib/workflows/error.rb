module Workflows
  # `ErrorValue` denotes an error.
  #
  # ```
  # data ReturnValue = ErrorValue value | value
  # ```
  #
  # In the context of Ruby and `Workflows` this means:
  # - a value represents an error iff it is an `ErrorValue`
  # - otherwise the value represents success
  #
  class ErrorValue < Struct.new(:value)
  end

  # `Error` provides helper functions for working with ErrorValue (and thus ReturnValue)
  module Error
    extend self

    # Returns `true` if `e` is an error
    def error?(e)
      ErrorValue === e
    end

    # Returns `false` if `e` is an error
    def success?(e)
      ! error?(e)
    end

    # Convert `e` into a value representing an error, if required.
    def to_error(e)
      case e
      when ErrorValue
        e
      else
        ErrorValue.new(e)
      end
    end

    # Composes a list of functions into a single function
    #
    # *Note* that this isn't a general purpose composition.
    #
    # The composed function and each constituent function have the same signature, roughly:
    # ```
    # fn :: void -> ReturnValue
    # ```
    #
    # *Note* that `void` is used here to mean "takes no arguments".
    # This is a dead giveaway that functions of this type signature will have side effects.
    #
    def compose_with_error_handling(*fns)
      fns.flatten.inject do |composed, fn|
        -> {
          last_return = composed.call
          if error?(last_return)
            last_return
          else
            fn.call
          end
        }
      end
    end
  end
end
