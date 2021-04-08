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
  it "creates a mock" do
    mock = MockClassToBeMocked.new
    mock.responds_to?(:method_with_no_parameters).should eq(true)
  end

  it "creates a mock that takes an optional name parameter for mock class" do
    mock = MockedClass.new
    mock.responds_to?(:method_with_no_parameters).should eq(true)
  end
end
