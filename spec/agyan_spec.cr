require "./spec_helper"

include Agyan

class ClassToBeMocked
  def method_with_no_parameters : Int32
    456
  end
end

mock_class(ClassToBeMocked)
mock_class(ClassToBeMocked, MockedClass)

describe Agyan do
  describe "mock class" do
    it "creates a mock" do
      mock = MockClassToBeMocked.new
      mock.responds_to?(:method_with_no_parameters).should eq(true)
    end

    it "creates a mock that takes an optional name parameter for mock class" do
      mock = MockedClass.new
      mock.responds_to?(:method_with_no_parameters).should eq(true)
    end

    it "returns a value specified by user" do
      mock = MockedClass.new
      return_value = 123
      MockedClass.on(mock, :method_with_no_parameters).with().then_return(return_value)
      mock.method_with_no_parameters.should eq(return_value)
    end

    it "returns different values when called different times" do
      mock = MockedClass.new
      return_value = 123
      return_value_two = 110
      MockedClass.on(mock, :method_with_no_parameters).with().then_return(return_value)
      MockedClass.on(mock, :method_with_no_parameters).with().then_return(return_value_two)
      mock.method_with_no_parameters.should eq(return_value)
      mock.method_with_no_parameters.should eq(return_value_two)
    end
  end
end
