module Workflows
  module Workflow
    private

    # Try a list of services (given as lambdas)
    # Bail and rollback if there are any failures
    def try_services(*services, success:, failure:)
      error_message = nil
      transaction_failure = lambda do |message|
        error_message = message
        raise ActiveRecord::Rollback
      end
      ActiveRecord::Base.transaction do
        # Pass success as nil when wrapping in a transaction
        # so that success is called in this context
        try_each(*services, success: nil, failure: transaction_failure)
        return success.call
      end
      failure.call(error_message)
    end

    # Try a list of services (given as lambdas)
    # Not wrapped in a transaction. Use at your own peril.
    def try_each(*services, success:, failure:)
      services.each do |service|
        value, error = service.call
        return failure.call(error) if error
      end
      success.call if success
    end
  end
end
