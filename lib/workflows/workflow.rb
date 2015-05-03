module Workflows
  module Workflow
    private

    def try_services(*fns, success: success, failure: failure)
      GenericWorkflow.call(*fns, success: success, failure: failure)
    end
  end
end
