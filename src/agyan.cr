module Agyan
  VERSION = "0.1.0"

  macro mock_class(type)
    class Mock{{ type.id }} < {{ type.id }}
    end
  end
end
