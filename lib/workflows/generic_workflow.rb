module Workflows
  module GenericWorkflow
    extend self
    extend Workflows::Error

    def call(fn, failure:, success:)
      error = nil

      ActiveRecord::Base.transaction do
        result = fn.call

        if error?(result)
          error = result
          raise ActiveRecord::Rollback
        end

        return success.arity == 1 ? success.call(result) : success.call
      end

      failure.call(error.value)
    end
  end
end
