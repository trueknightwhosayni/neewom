module Neewom
  class AbstractForm
    include Neewom::Proxies::BuildersAndFinders

    include Neewom::Serializer
    
    attr_accessor :id, :repository_klass, :template, :fields, :persist_submit_controls

    def self.build(config)
      form = self.new
      form.id = config[:id]
      form.repository_klass = config[:repository_klass]
      form.template = config[:template]
      form.persist_submit_controls = config[:persist_submit_controls]

      form.fields = config[:fields].map do |name, field_config|
        field = Neewom::AbstractField.new

        field_config = { input: field_config } if field_config.is_a?(String)

        field.name              = name
        field.label             = field_config[:label]        
        field.input             = field_config[:input]
        field.virtual           = field_config[:virtual]
        field.validations       = field_config[:validations]
        field.collection        = field_config[:collection]
        field.collection_klass  = field_config[:collection_klass]
        field.collection_method = field_config[:collection_method]
        field.collection_params = field_config[:collection_params]
        field.label_method      = field_config[:label_method]
        field.value_method      = field_config[:value_method]
        field.input_html        = field_config[:input_html]
        field.custom_options    = field_config[:custom_options]

        field
      end

      form
    end

    def fields
      @fields || []
    end

    def template
      @template || 'form'
    end  

    def virtual_fields
      fields.select(&:virtual)
    end

    def submit_fields
      fields.select(&:submit?)
    end

    def persisted_fields
      persist_submit_controls ? fields : fields.reject(&:submit?)
    end

    def store!
      Neewom::Repository.new.store!(self)
    end  
  end
end