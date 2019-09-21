require 'zlib'

module Neewom
  class Repository
    def store!(abstract_form)
      form_record = Neewom::CustomForm.find_by key: abstract_form.id
      current_crc = calculate_crc32(abstract_form)

      return if form_record.present? && form_record.crc32 == current_crc

      form_record ||= Neewom::CustomForm.new(key: abstract_form.id)

      form_record.transaction do
        form_record.assign_attributes(
          repository_klass: abstract_form.repository_klass, 
          template: abstract_form.template, 
          crc32: current_crc, 
          persist_submit_controls: (abstract_form.persist_submit_controls || false)
        )
        existing_fields = form_record.custom_fields.to_a

        abstract_form.fields.each_with_index do |field, index|
          if field.collection.present?
            raise "Form with specified collection could not be stored."  
          end
                    
          field_record = existing_fields.find { |item| item.name.to_s == field.name.to_s }
          field_record ||= Neewom::CustomField.new(custom_form: form_record, name: field.name)

          field_record.update!(
            order:             index,
            label:             field.label,
            input:             field.input,
            virtual:           field.virtual,
            validations:       field.validations.to_json,
            collection_klass:  field.collection_klass,
            collection_method: field.collection_method,
            collection_params: field.collection_params.to_json,
            label_method:      field.label_method,
            value_method:      field.value_method,
            input_html:        field.input_html.to_json,
            custom_options:    field.custom_options.to_json
          )

          form_record.custom_fields << field_record
        end

        removable_fields = existing_fields.select { |item| abstract_form.fields.none? { |f| f.name.to_s == item.name.to_s } }
        removable_fields.each(&:destroy)
        
        form_record.save!
      end

      form_record
    end

    def fetch!(form_record)
      form = Neewom::AbstractForm.new
      form.id                      = form_record.key
      form.repository_klass        = form_record.repository_klass
      form.template                = form_record.template
      form.persist_submit_controls = form_record.persist_submit_controls

      form.fields = form_record.custom_fields.map do |field_record|
        field = Neewom::AbstractField.new
        field.label             = field_record.label
        field.name              = field_record.name
        field.input             = field_record.input
        field.virtual           = field_record.virtual
        field.validations       = JSON.parse(field_record.validations, symbolize_names: true)
        field.collection_klass  = field_record.collection_klass
        field.collection_method = field_record.collection_method
        field.collection_params = JSON.parse(field_record.collection_params)&.map(&:to_sym)
        field.label_method      = field_record.label_method
        field.value_method      = field_record.value_method
        field.input_html        = JSON.parse(field_record.input_html, symbolize_names: true)
        field.custom_options    = JSON.parse(field_record.custom_options, symbolize_names: true)

        field
      end

      form
    end

    private 

    def calculate_crc32(abstract_form)
      buff = [abstract_form.id, abstract_form.repository_klass, abstract_form.template, abstract_form.persist_submit_controls].join(':')

      buff += abstract_form.fields.map do |field|
        [
          field.label,
          field.name,
          field.input,
          field.virtual,
          field.validations.to_json,
          field.collection_klass,
          field.collection_method,
          field.collection_params.to_json,
          field.label_method,
          field.value_method,
          field.input_html.to_json,
          field.custom_options.to_json
        ].map(&:to_s)
      end.flatten.join(':')
      
      Zlib::crc32(buff).to_s
    end 
  end  
end