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
end
