# Agyan (अज्ञान, Ajñāna)

An [idiomatic](idiomatic-definition) mocking library for Crystal 💎

[Meaning](meaning-of-agyan) of Agyan.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   development_dependencies:
     agyan:
       github: tkshnwesper/agyan
   ```

2. Run `shards install`

## Usage

### How to use the library in a nutshell

1. Create a mock class
2. Instantiate the above class into an object
3. Setup expectations and return values for methods on that object
4. Pass that object into the code that you want to test

### Import the library

```crystal
require "agyan"

import Agyan
```

### Create a `class` mock

`mock_class` can only be called at the root level or in modules, because it is a macro that creates a mock class, and classes have a limitation that they cannot be created inside methods.

```crystal
class Garden
end

mock_class(Garden)  # Creates class called `MockGarden`
```

### It also takes an optional name parameter

```crystal
class Rocket
  def blast_off
  end
end

mock_class(Rocket, MockedRocket)  # Creates class called `MockedRocket`

# `blast_off` can now be mocked on an instance of `MockedRocket`
```

### Define return values

```crystal
class Vault
  def open : Bool
  end
end

mock_class(Vault)

describe Vault do
  it "opens vault" do
    mock = MockVault.new
    MockVault.on(mock, :open).with.then_return(true)
    mock.open.should be_truthy
  end
end
```

### Return only when specific parameters are passed

```crystal
class Vault
  def open(pin : Int32) : Bool
  end
end

mock_class(Vault)

describe Vault do
  it "opens vault" do
    mock = MockVault.new
    MockVault.on(mock, :open).with(123).then_return(true)
    mock.open(123).should be_truthy
  end
end
```

### Assert expectations

Check whether your code is calling the mocked methods with the correct parameters.

```crystal
class Vault
  def open(pin : Int32) : Bool
  end
end

mock_class(Vault)

describe Vault do
  it "opens vault" do
    mock = MockVault.new
    MockVault.on(mock, :open).with(123).then_return(true)
    MockVault.assert_expectations(mock) # raises exception as `open` is not called with `(123)`
  end
end
```

### There is also support for overridden methods

```crystal
class Vault
  def open(pin : Int32) : Bool
  end

  def open(pin : String) : Bool
  end
end

mock_class(Vault)

describe Vault do
  it "opens vault" do
    mock = MockVault.new
    MockVault.on(mock, :open).with(123).then_return(true)
    MockVault.on(mock, :open).with("Agyan").then_return(false)
    mock.open(123).should be_truthy
    mock.open("Agyan").should be_falsey
  end
end
```

## Development

Run tests using

```
crystal spec
```

## Contributing

1. Fork it (<https://github.com/tkshnwesper/agyan/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Saurabh Machave](https://github.com/tkshnwesper) - creator and maintainer

[idiomatic-definition]: https://www.lexico.com/definition/idiomatic
[meaning-of-agyan]: (https://www.wisdomlib.org/definition/ajnana#sanskrit)
