module Workflows
  # helper mixin for Workflows
  module WorkflowHelper
    private

    def try_services(*fns, success:, failure:)
      Workflows::Workflow.call_each(*fns, success: success, failure: failure)
    end
  end
end
