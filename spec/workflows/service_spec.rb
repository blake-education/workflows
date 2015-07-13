require 'spec_helper'

describe Workflows::Service do
  module UnderTest
    extend Workflows::Service
  end

  it 'makes value successy' do
    expect(Workflows::Error.success?(UnderTest.success!(:a))).to eq(true)
  end

  it 'makes value errory' do
    expect(Workflows::Error.error?(UnderTest.failure!(:a))).to eq(true)
  end

  describe '.compose_with_error_handling' do
    it 'composes lambdas' do
      handled = []

      r = subject.compose_with_error_handling(
        -> { handled << :a; "first" },
        [ 
          -> { handled << :b; "array[0]" },
          nil,
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

    it 'returns a success lambda if composition flattens to nil' do
      r = subject.compose_with_error_handling([[], [nil], nil])
      expect(subject).to receive(:success!).and_call_original
      expect(r.call).to eq(true)
    end
  end

  describe '.call_each' do
    it 'allows nesting of services' do
      handled = []

      subject.call_each(
        -> { handled << :a },
        -> do
          subject.call_each(
            -> { handled << :b_a },
            -> { handled << :b_b },
          )
        end,
        -> { handled << :c }
      )
      expect(handled).to eq([:a, :b_a, :b_b, :c])
    end
  end
end
