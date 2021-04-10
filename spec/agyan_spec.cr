require "./spec_helper"

include Agyan

class ClassToBeMocked
  def some_method : Int32
    456
  end

  def some_method(num : Int32) : Int32
    num * 456
  end
end

mock_class(ClassToBeMocked)
mock_class(ClassToBeMocked, MockedClass)

describe Agyan do
  describe "mock class" do
    it "creates a mock" do
      mock = MockClassToBeMocked.new
      mock.responds_to?(:some_method).should eq(true)
    end

    it "creates a mock that takes an optional name parameter for mock class" do
      mock = MockedClass.new
      mock.responds_to?(:some_method).should eq(true)
    end

    it "returns a value specified by user" do
      mock = MockedClass.new
      return_value = 123
      MockedClass.on(mock, :some_method).with.then_return(return_value)
      mock.some_method.should eq(return_value)
    end

    it "returns different values when called different times" do
      mock = MockedClass.new
      return_value = 123
      return_value_two = 110
      MockedClass.on(mock, :some_method).with.then_return(return_value)
      MockedClass.on(mock, :some_method).with.then_return(return_value_two)
      mock.some_method.should eq(return_value)
      mock.some_method.should eq(return_value_two)
    end

    it "mocks a overridden method" do
      mock = MockedClass.new
      return_value = 123
      return_value_two = 110
      MockedClass.on(mock, :some_method).with.then_return(return_value)
      MockedClass.on(mock, :some_method).with(110).then_return(return_value_two)
      mock.some_method.should eq(return_value)
      mock.some_method(110).should eq(return_value_two)
    end
  end
end
