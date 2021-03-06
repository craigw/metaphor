require 'spec_helper'
require 'metaphor/processor/wiretap'

describe Metaphor::Processor::Wiretap do
  before(:each) do
    @default_destination = stub_everything('Default Destination')
    @wiretap_destination  = stub_everything('Wiretap Destination')
    @wiretap = Metaphor::Processor::Wiretap.new @default_destination,
                                                @wiretap_destination
  end

  it "is inactive by default" do
    @wiretap.should_not be_active
  end

  it "can be activated" do
    @wiretap.activate
    @wiretap.should be_active
  end

  describe "when inactive" do
    it "routes messages to only the default destination" do
      message = "test message"
      @wiretap_destination.expects(:call).never
      @default_destination.expects(:call).once.with(message)
      @wiretap.call(message)
    end
  end

  describe "when active" do
    before(:each) do
      @wiretap.activate
    end

    it "routes the same message to both destinations" do
      message = "test message"
      route = sequence('route')
      @wiretap_destination.expects(:call).once.with(message).in_sequence(route)
      @default_destination.expects(:call).once.with(message).in_sequence(route)
      @wiretap.call(message)
    end

    it "can be deactivated" do
      @wiretap.deactivate
      @wiretap.should_not be_active
    end
  end

  after(:each) do
    @wiretap = nil
  end
end
