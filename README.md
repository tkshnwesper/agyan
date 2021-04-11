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

```crystal
require "agyan"

import Agyan
```

### Create a `class` mock

```crystal
class Garden
end

mock_class(Garden)  # Creates class called `MockGarden`
```

### It also takes an optional name parameter

```crystal
class Rocket
end

mock_class(Rocket, MockedRocket)  # Creates class called `MockedRocket`
```

### Define return values

```crystal
class Farm
  def get_animals : Array(String)
  end
end

mock_class(Farm)

describe Farm do
  it "fetches animals" do
    mock = MockFarm.new
    MockFarm.on(mock, :get_animals).then_return(["Piggy", "Horsey", "Donkey"])
    mock.get_animals.should eq(["Piggy", "Horsey", "Donkey"])
  end
end
```

### There is also support for overridden methods

```crystal
class Vault
  def check_pin(pin : Int32) : Bool
  end

  def check_pin(pin : String) : Bool
  end
end

mock_class(Vault)

describe Vault do
  it "checks pin" do
    mock = MockVault.new
    MockVault.on(mock, :check_pin).with(123).then_return(true)
    MockVault.on(mock, :check_pin).with("Agyan").then_return(false)
    mock.check_pin(123).should be_truthy
    mock.check_pin("Agyan").should be_falsey
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
