module Gdocs
  module Concerns
    module Attributes
      def self.included(base)
        base.extend(ClassMethods)
      end

    private

      module ClassMethods
        def document_attributes(*attributes)
          attributes.each do |attribute|
            m = attribute.to_sym
            define_method(m) do
              # to_s.camelize(:lower) - if we have ActiveSupport as dependency
              field = m.to_s.split('_').inject([]){ |buffer, e| buffer + [buffer.empty? ? e : e.capitalize] }.join
              value = instance_variable_get("@#{m.to_s}") || instance_variable_set("@#{m.to_s}", @data[field])
              value
            end
          end
        end
      end
    end
  end
end
