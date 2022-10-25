require 'gdocs/utils/string'

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
              field = m.to_s.camelize_lower
              value = instance_variable_get("@#{m.to_s}") || instance_variable_set("@#{m.to_s}", @data[field])
              value
            end
          end
        end
      end
    end
  end
end
