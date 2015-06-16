module Workflows
  # helper mixin for Workflows
  module Workflow
    extend self
    extend Workflows::Error

    # Execute `fn` within an `ActiveRecord` transaction.
    #
    # Rough types:
    # ```
    # fn :: void -> ReturnValue
    # failure :: value -> NilClass
    #
    # success :: value -> NilClass
    # # or 
    # success :: void -> NilClass
    # ```
    #
    # If `fn` returns an `ErrorValue`, roll back the transaction and call `failure` with the unwrapped error `value`.
    # Otherwise commit the transaction and call success. 
    def call(fn, failure:, success:)
      error = nil
      result = nil

      ActiveRecord::Base.transaction do
        result = fn.call

        if error?(result)
          error = result
          raise ActiveRecord::Rollback
        end
      end

      if error
        failure.call(error.value)
      else
        success.arity == 1 ? success.call(result) : success.call
      end
    end

    # `call_each` composes a list of functions into a single function
    # which it then passes along to a `call` to perform the workflow logic.
    #
    # Each fn should have the rough type:
    # ```
    # fn :: void -> ReturnValue
    # ```
    #
    def call_each(*fns, failure:, success:)
      call compose_with_error_handling(*fns), failure: failure, success: success
    end

    # Composes a list of functions into a single function.
    #
    # *Note* that this isn't a general purpose composition.
    # *Note* a function here is anything that responds to `call` i.e. lambda or a singleton module.
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
      fns.flatten.compact.inject do |composed, fn|
        -> {
          last_return = composed.call
          if Workflows::Error.error?(last_return)
            last_return
          else
            fn.arity > 0 ? fn.curry[last_return] : fn.call
          end
        }
      end
    end
  end
end
