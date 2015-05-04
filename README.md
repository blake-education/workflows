# Workflows

Execute `Services` with convenient error handling.

## Example

```ruby
module DeleteWidgetWorkflow
  extend self

  def call(widget, failure:, success:)
    Workflows::Workflow.call_each
      -> { UnTwiddleWidgetService.call(widget) },
      -> { WidgetDestructorService.call(widget) },
      failure: failure, success: success
  end
end

module Fooprogs < ApplicationController
  def create
    widget = Widget.new(params[:widget_id])

    Workflows::Workflow.call -> { TwiddleWidgetService.call(widget) },
      failure: ->(err) { render 500 },
      success: -> { render "ok" },
  end

  def delete
    widget = Widget.new(params[:widget_id])

    DeleteWidgetWorkflow.call widget, failure: ->(err) {}, success: ->{}
  end
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/workflows/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
