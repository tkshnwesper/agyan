module Agyan
  VERSION = "0.1.0"

  macro on_list(method)
    @__on_list__{{ method.name }}
  end

  macro mock_class(type, name = nil)
    class {% if name %} {{name}} {% else %} Mock{{type.id}} {% end %} < {{ type.id }}
      {% for method in type.resolve.methods %}
        @__on_list__{{ method.name }} = [] of Parameters_{{ method.name }}
        def {{ method.name }}({{ *method.args }})
          parameters = @__on_list__{{ method.name }}.shift?
          raise "Mock for the method {{ method.name }} not found" unless parameters
          parameters.get_return_value
        end
        def __on__{{ method.name }}(parameters : Parameters_{{ method.name }})
          @__on_list__{{ method.name }} << parameters
        end
        class Parameters_{{ method.name }} < Parameters
          def with({{ *method.args }})
            {% for arg in method.args %}
              @{{ arg.name }} = {{ arg.name }}
            {% end %}
            self
          end
          def then_return(@return_value : {{ method.return_type.resolve.id }})
            raise "Nil return value provided" unless @return_value
          end
          def get_return_value
            raise "Please provide a return value for the method {{ method.name }}" unless @return_value
            @return_value
          end
        end
      {% end %}
      def self.on(mock : self, method : Symbol)
        {% begin %}
          case method
          {% for method in type.resolve.methods %}
            when :{{ method.name }}
              parameters = Parameters_{{ method.name }}.new
              mock.__on__{{ method.name }}(parameters)
          {% end %}
          else
            raise "Method #{method} not found in class"
          end
          {% end %}
        parameters
      end
    end
  end

  private class Parameters
    def get_return_value
    end
  end

  private class On
    def initialize(@method : Symbol, @parameters : Parameters)
    end

    def get_parameters
      @parameters
    end

    def method_eq?(method_name)
      @method == method_name
    end
  end
end
