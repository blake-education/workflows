module Workflows
  module GenericWorkflow
    extend self
    extend Workflows::Error

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
