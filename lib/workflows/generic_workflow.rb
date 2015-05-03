module Workflow
  module GenericWorkflow
    extend self

    def call(*fns, failure:, success:)
      fn = Workflows::Error.compose_with_error_handling(*fns)
      error = nil

      ActiveRecord::Base.transaction do
        result = fn.call

        if error?(result)
          error = result
          raise ActiveRecord::Rollback
        end

        return success.call(result)
      end

      failure.call(error.value)
    end
  end
end
