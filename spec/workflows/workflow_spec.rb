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
  include Workflows::Workflow

  let(:messages) { [] }
  let(:calls) { [] }

  let(:successful_fn) { ->{ calls << :success; :success } }
  let(:failure_fn) { ->{ calls << :failed; Workflows::ErrorValue.new(:failed) } }

  let(:success) { ->(v) { messages << v } }
  let(:failure) { ->(v) { messages << v } }

  it "runs a successful workflow" do
    try_services(
      successful_fn,
      successful_fn,
      successful_fn,
      success: success, failure: failure)

    expect(calls).to eq([:success, :success, :success])
    expect(messages).to eq([:success])
  end

  it "runs an unsuccessful workflow" do
    try_services(
      successful_fn,
      failure_fn,
      successful_fn,
      success: success, failure: failure)

    expect(calls).to eq([:success, :failed])
    expect(messages).to eq([:failed])
  end
end
