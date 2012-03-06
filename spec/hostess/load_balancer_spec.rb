require "spec_helper"

# https://www.relishapp.com/rspec/rspec-expectations/docs

describe Hostess::LoadBalancer do
  it "should exist" do
    Hostess::LoadBalancer.should be
  end

  describe "#list" do
    pending
  end
end