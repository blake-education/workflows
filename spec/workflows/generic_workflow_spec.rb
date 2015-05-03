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

describe Workflows::GenericWorkflow do
  let(:messages) { [] }

  let(:successful_fn) { ->{ :success } }
  let(:failure_fn) { ->{ Workflows::ErrorValue.new(:failed) } }

  let(:success) { ->(v) { messages << v } }
  let(:failure) { ->(v) { messages << v } }

  it "runs a successful workflow" do
    subject.call(successful_fn, success: success, failure: failure)
    expect(messages).to eq([:success])
  end

  it "runs an unsuccessful workflow" do
    subject.call(failure_fn, success: success, failure: failure)
    expect(messages).to eq([:failed])
  end
end
