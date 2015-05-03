module Workflows
  module Service
    def success!(value=nil)
      if value
        value
      else
        true
      end
    end

    def failure!(value=false)
      Workflows::Error.to_error(value)
    end
  end
end
