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

        protected def __on__{{ method.name }}(parameters : Parameters_{{ method.name }})
          @__on_list__{{ method.name }} << parameters
        end

        private class Parameters_{{ method.name }}
          def with({{ *method.args }})
            {% for arg in method.args %}
              @{{ arg.name }} = {{ arg.name }}
            {% end %}
            self
          end

          def then_return(@return_value : {{ method.return_type.resolve.id }})
          end

          def get_return_value
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
end
