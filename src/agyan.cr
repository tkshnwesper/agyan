module Agyan
  VERSION = "0.1.0"

  macro mock_class(type, name = nil)
    class {% if name %} {{name}} {% else %} Mock{{type.id}} {% end %} < {{ type.id }}
      {% for method in type.resolve.methods %}
        @__on_list__{{ method.name }} = [] of Parameters_{{ method.name }}
        def {{ method.name }}({{ *method.args }})
          parameters = @__on_list__{{ method.name }}.select do |parameter|
            parameter.is_arg_match?({{ *method.args.map &.name }}) && !parameter.is_returned?
          end
          raise "Mock for the method {{ method.name }} not found" unless parameters.size > 0
          parameters.first.get_return_value!
        end

        protected def __on__{{ method.name }}(parameters : Parameters_{{ method.name }})
          @__on_list__{{ method.name }} << parameters
        end

        private class Parameters_{{ method.name }}
          getter? is_returned = false

          def with({{ *method.args }})
            {% for arg in method.args %}
              @__arg_{{ arg.name }} = {{ arg.name }}
            {% end %}
            self
          end

          def is_arg_match?({{ *method.args }})
            {% for arg in method.args %}
              @__arg_{{ arg.name }} == {{ arg.name }} &&
            {% end %}
            true
          end

          def then_return(@return_value : {{ method.return_type.resolve.id }})
          end

          def get_return_value!
            @is_returned = true
            @return_value
          end
        end
      {% end %}

      def self.on(mock : self, method : Symbol)
        {% methods = [] of Crystal::Macros::MacroId %}
        {% for method_type in type.resolve.methods %}
          {% methods << method_type.name %}
        {% end %}
        {% methods = methods.uniq %}
        {% begin %}
          case method
          {% for method_name in methods %}
            when :{{ method_name }}
              parameters = Parameters_{{ method_name }}.new
              mock.__on__{{ method_name }}(parameters)
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
