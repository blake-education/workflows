module Workflows
  module Service
    extend self

    def success!(value=true)
      value
    end

    def failure!(value=false)
      Workflows::Error.to_error(value)
    end
  end
end
