require 'spec_helper'
require 'metaphor/processor/detour'

describe Metaphor::Processor::Detour do
  before(:each) do
    @default_destination = stub_everything('Default Destination')
    @detour_destination  = stub_everything('Detour Destination')
    @detour = Metaphor::Processor::Detour.new @default_destination,
                                              @detour_destination
  end

  it "is inactive by default" do
    @detour.should_not be_active
  end

  it "can be activated" do
    @detour.activate
    @detour.should be_active
  end

  describe "when inactive" do
    it "routes messages to the default destination" do
      message = "test message"
      @detour_destination.expects(:call).never
      @default_destination.expects(:call).once.with(message)
      @detour.call(message)
    end
  end

  describe "when active" do
    before(:each) do
      @detour.activate
    end

    it "routes messages to the detour destination" do
      message = "test message"
      @detour_destination.expects(:call).once.with(message)
      @detour.call(message)
    end

    it "routes the detoured message to the default destination after the detour" do
      message = "test message"
      detoured_message = "detoured test message"
      route = sequence('route')
      @detour_destination.expects(:call).once.with(message).in_sequence(route).returns(detoured_message)
      @default_destination.expects(:call).once.with(detoured_message).in_sequence(route)
      @detour.call(message)
    end

    it "can be deactivated" do
      @detour.deactivate
      @detour.should_not be_active      
    end
  end

  after(:each) do
    @detour = nil
  end
end
