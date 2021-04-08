module Agyan
  VERSION = "0.1.0"

  macro mock_class(type, name = nil)
    class {% if name %} {{name}} {% else %} Mock{{type.id}} {% end %} < {{ type.id }}
    end
  end
end
