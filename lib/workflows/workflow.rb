module Workflows
  # helper mixin for Workflows
  module Workflow
    private

    # `try_services` composes a list of functions into a single function
    # which it then passes along to a `GenericWorkflow` to perform the workflow logic.
    #
    # Each fn should have the rough type:
    # ```
    # fn :: void -> ReturnValue
    # ```
    #
    def try_services(*fns, success: success, failure: failure)
      GenericWorkflow.call(Workflows::Error.compose_with_error_handling(*fns), success: success, failure: failure)
    end
  end
end
