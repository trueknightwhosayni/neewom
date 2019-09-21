require 'zlib'

module Neewom
  module Serializer
    # It looks like it may have sense to store an input config and return it.
    # However theare some fields are not serializable and also there are default values.

    def to_h
      result = {}
      result[:id] = id
      result[:repository_klass] = repository_klass
      result[:template] = template
      result[:fields] = {}

      fields.each do |field|
        field_data = {}
        field_data[:label]              = field.label
        field_data[:input]              = field.input
        field_data[:validations]        = field.validations
        field_data[:collection_klass]   = field.collection_klass
        field_data[:collection_method]  = field.collection_method
        field_data[:collection_params]  = field.collection_params
        field_data[:label_method]       = field.label_method
        field_data[:value_method]       = field.value_method
        field_data[:input_html]         = field.input_html
        field_data[:custom_options]     = field.custom_options

        result[:fields][field.name.to_sym] = field_data 
      end

      result
    end

    def to_json
      to_hash.to_json
    end
  end  
end