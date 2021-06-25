module Neewom
  module Model
    extend ActiveSupport::Concern

    included do
      attr_accessor :neewom_form

      def initialize_neewom_attributes(key_or_form)
        self.neewom_form =
          case key_or_form
          when Neewom::AbstractForm
            key_or_form
          when Neewom::CustomForm
            key_or_form.to_form
          else
            Neewom::CustomForm.find_by!(key: key_or_form).to_form
          end

        initialize_neewom_view neewom_form.virtual_fields.map(&:name).map(&:to_sym)

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

        self
      end
      alias_method :neewom, :initialize_neewom_attributes

      def initialize_neewom_view(*names)
        data_column = self.class.neewom_attributes_column

        names.each do |name|
          singleton_class.class_eval do
            store_accessor data_column, name
          end
        end

        self
      end
      alias_method :neewom_view, :initialize_neewom_view
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
