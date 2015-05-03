module Workflows
  module Workflow
    private

    def try_services(*fns, success: success, failure: failure)
      GenericWorkflow.call(Workflows::Error.compose_with_error_handling(*fns), success: success, failure: failure)
    end
  end
end
