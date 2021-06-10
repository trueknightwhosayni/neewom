module Neewom
  module Model
    extend ActiveSupport::Concern

    included do
      attr_accessor :neewom_form

      def initialize_neewom_attributes(key_or_form)
        data_column = self.class.neewom_attributes_column

        self.neewom_form =
          case key_or_form
          when Neewom::AbstractForm
            key_or_form
          when Neewom::CustomForm
            key_or_form.to_form
          else
            Neewom::CustomForm.find_by!(key: key_or_form).to_form
          end

        neewom_form.virtual_fields.map do |field|
          name = field.name.to_sym

          singleton_class.class_eval do
            store_accessor data_column, name
          end
        end

        neewom_form.fields.map do |field|
          name = field.name.to_sym
          validations_config = field.validations

          singleton_class.class_eval do
            if validations_config.present?
              Array(validations_config).each do |config|
                next if config.blank?

                validates *[name, config]
              end
            end
          end
        end
      end
    end

    module ClassMethods
      attr_accessor :neewom_attributes_column

      def has_neewom_attributes(column)
        self.neewom_attributes_column = column
        serialize column, Hash
      end
    end
  end
end
