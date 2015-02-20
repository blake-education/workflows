module Workflows
  module Service
    def success!(msg=nil)
      [msg || true, nil]
    end

    def failure!(msg)
      [nil, msg]
    end
  end
end
