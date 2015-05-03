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

        return success.call(result)
      end

      failure.call(error.value)
    end
  end
end
