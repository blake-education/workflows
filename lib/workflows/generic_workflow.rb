module Workflows
  module GenericWorkflow
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
  end
end
