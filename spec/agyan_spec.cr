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

class ClassWithInitialize
  def initialize(value : Int32)
  end
end

mock_class(ClassToBeMocked)
mock_class(ClassToBeMocked, MockedClass)
mock_class(ClassWithInitialize)

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

    it "raises an exception when trying to mock that the class does not have" do
      mock = MockedClass.new
      return_value = 123
      expect_raises Exception, "Method other_method not found in class" do
        MockedClass.on(mock, :other_method).with(45).then_return(return_value)
      end
    end

    it "returns a value specified by user" do
      mock = MockedClass.new
      return_value = 123
      MockedClass.on(mock, :some_method).with.then_return(return_value)
      mock.some_method.should eq(return_value)
    end

    it "raises exception when method is not mocked" do
      mock = MockedClass.new
      return_value = 123
      expect_raises Exception, "Mock for the method some_method not found" do
        mock.some_method.should eq(return_value)
      end
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
      mock.some_method(110).should eq(return_value_two)
      mock.some_method.should eq(return_value)
    end

    it "raises an error on failed assertion of expectation" do
      mock = MockedClass.new
      return_value = 123
      MockedClass.on(mock, :some_method).with.then_return(return_value)
      expect_raises Exception, "`some_method` was not called on a `MockedClass` instance" do
        MockedClass.assert_expectations(mock)
      end
    end

    it "asserts expectation successfully" do
      mock = MockedClass.new
      return_value = 123
      MockedClass.on(mock, :some_method).with.then_return(return_value)
      mock.some_method.should eq(123)
      MockedClass.assert_expectations(mock)
    end

    it "mocks initialize methods" do
      MockClassWithInitialize.on(:initialize).with(10)
      mock = MockClassWithInitialize.new(10)
      MockClassWithInitialize.assert_expectations(mock)
    end
  end
end
