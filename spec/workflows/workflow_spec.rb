require 'spec_helper'

# mock out ActiveRecord
module ActiveRecord
  class Rollback < StandardError; end
  class Base
    def self.transaction(&blk)
      begin
        yield
      rescue Rollback
      end
    end
  end
end

describe Workflows::Workflow do
  context ".call" do
    let(:messages) { [] }

    let(:successful_fn) { ->{ :success } }
    let(:failure_fn) { ->{ Workflows::ErrorValue.new(:failed) } }

    let(:success) { ->(v) { messages << v } }
    let(:success_no_arg) { -> { messages << :success_no_arg } }
    let(:failure) { ->(v) { messages << v } }

    it "runs a successful workflow, with success result" do
      subject.call(successful_fn, success: success, failure: failure)
      expect(messages).to eq([:success])
    end

    it "runs a successful workflow, without success result" do
      subject.call(successful_fn, success: success_no_arg, failure: failure)
      expect(messages).to eq([:success_no_arg])
    end

    it "runs an unsuccessful workflow" do
      subject.call(failure_fn, success: success, failure: failure)
      expect(messages).to eq([:failed])
    end

  end

  context ".call_each" do
    let(:messages) { [] }
    let(:calls) { [] }

    let(:successful_fn) { ->{ calls << :success; :success } }
    let(:failure_fn) { ->{ calls << :failed; Workflows::ErrorValue.new(:failed) } }

    let(:success) { ->(v) { messages << v } }
    let(:failure) { ->(v) { messages << v } }

    it "runs a successful workflow" do
      subject.call_each(
        successful_fn,
        successful_fn,
        successful_fn,
        success: success, failure: failure)

      expect(calls).to eq([:success, :success, :success])
      expect(messages).to eq([:success])
    end

    it "runs an unsuccessful workflow" do
      subject.call_each(
        successful_fn,
        failure_fn,
        successful_fn,
        success: success, failure: failure)

      expect(calls).to eq([:success, :failed])
      expect(messages).to eq([:failed])
    end
  end

  context '.compose_with_error_handling' do
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

    it 'composes lambdas with arity > 0 ala function composition' do
      handled = []

      r = subject.compose_with_error_handling(
        -> { handled << :a; "first" },
        [
          ->(input) { handled << :b; "array[0] #{input}" },
          nil,
          ->(input) { handled << :c; "array[1] #{input}" },
        ],
        ->(input) { handled << :d; "last #{input}" }
      ).call

      expect(handled).to eq([:a, :b, :c, :d])
      expect(r).to eq("last array[1] array[0] first")
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
end
