module Agyan
  VERSION = "0.1.0"

  macro mock_class(type, name = nil)
    class {% if name %} {{ name }} {% else %} Mock{{ type.id }} {% end %} < {{ type.id }}
      {% for method in type.resolve.methods %}
        getter __on_list__{{ method.name }} = [] of Parameters_{{ method.name }}

        def {{ method.name }}({{ *method.args }}) {% if method.name != :initialize %} : {{ method.return_type }} {% end %}
          parameters = @__on_list__{{ method.name }}.select do |parameter|
            parameter.is_arg_match?({{ *method.args.map &.name }}) && !parameter.is_returned?
          end
          raise "Mock for the method {{ method.name }} not found" unless parameters.size > 0

          parameters.first.is_returned = true

          {% if method.name != :initialize %}
            return_type = parameters.first.return_type
            raise "return_type Nil should not be returned for {{ method.name }}" if return_type.nil?
            return return_type.return_value.as({{ method.return_type }})
          {% else %}
            nil
          {% end %}
        end

        protected def __on__{{ method.name }}(parameters : Parameters_{{ method.name }})
          @__on_list__{{ method.name }} << parameters
        end
      {% end %}

      {% methods = [] of Crystal::Macros::MacroId %}
      {% for method in type.resolve.methods %}
        {% methods << method.name %}
      {% end %}
      {% methods = methods.uniq %}

      {% for method_name in methods %}
        {%
          methods = type.resolve.methods.select do |method|
            method.name == method_name
          end
          return_types = methods.map &.return_type
          unique_return_types = return_types.uniq
        %}

        {% if method_name != :initialize %}
          {% for return_type in unique_return_types %}
            class ReturnType_{{ method_name }}_{{ return_type }}
              getter return_value : Nil | {{ return_type }}

              def then_return(@return_value : {{ return_type }})
              end
            end
          {% end %}
        {% end %}

        class Parameters_{{ method_name }}
          property? is_returned : Bool = false

          {% if method_name != :initialize %}
            getter return_type : Nil {% for return_type in unique_return_types %}| ReturnType_{{ method_name }}_{{ return_type }}{% end %}
          {% end %}

          {% for method in type.resolve.methods %}
            {% if method_name == method.name %}
              def with({{ *method.args }}){% if method_name != :initialize %} : ReturnType_{{ method_name }}_{{ method.return_type }}{% end %}
                {% for arg in method.args %}
                  @__arg_{{ arg.name }} = {{ arg.name }}
                {% end %}
                {% if method_name != :initialize %}
                  @return_type = ReturnType_{{ method_name }}_{{ method.return_type }}.new
                {% else %}
                  nil
                {% end %}
              end

              def is_arg_match?({{ *method.args }})
                {% for arg in method.args %}
                  @__arg_{{ arg.name }} == {{ arg.name }} &&
                {% end %}
                true
              end
            {% end %}
          {% end %}
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

      def self.assert_expectations(mock : self)
        {% for method in type.resolve.methods %}
          not_called_expectations = mock.__on_list__{{ method.name }}.select do |parameter|
            !parameter.is_returned?
          end
          raise "`{{ method.name }}` was not called on a `#{mock.class}` instance" if not_called_expectations.size > 0
        {% end %}
      end
    end
  end
end
