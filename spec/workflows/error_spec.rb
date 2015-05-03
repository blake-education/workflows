require 'spec_helper'

describe Workflows::Error do
  it 'composes lambdas' do
    handled = []

    r = subject.compose_with_error_handling(
      -> { handled << :a; "first" },
      [ 
        -> { handled << :b; "array[0]" },
        -> { handled << :c; "array[1]" },
      ],
      -> { handled << :d; "last" }
    ).call

    expect(handled).to eq([:a, :b, :c, :d])
    expect(r).to eq("last")
  end

  it 'composes error handling' do
    handled = []
    r = subject.compose_with_error_handling(
      -> { handled << :a; "first" },
      -> { handled << :b; Workflows::ErrorValue.new("error") },
      -> { handled << :c; "last" }
    ).call

    expect(handled).to eq([:a, :b])
    expect(r).to be_instance_of(Workflows::ErrorValue)
    expect(r.value).to eq("error")
  end
end
