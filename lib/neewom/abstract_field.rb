module Neewom
  class AbstractField
    # This constant can be changed OUTSIDE !!!
    SUPPORTED_FIELDS = [
      # 'check_box_collection',
      EMAIL               = 'email_field',
      HIDDEN              = 'hidden_field',
      NUMBER              = 'number_field',
      PASSWORD            = 'password_field',
      PHONE               = 'phone_field',
      # 'radio_button_collection',
      SELECT              = 'select_field',
      MULTIPLE_SELECT     = 'multiple_select_field',
      SUBMIT              = 'submit',
      TEXTAREA            = 'text_area',
      TEXT                = 'text_field',
      CHECKBOX            = 'checkbox',
      FILE                = 'file',
      DATEPICKER          = 'datepicker',
      TIMEPICKER          = 'timepicker',
      DATETIMEPICKER      = 'datetimepicker'
    ]

    attr_accessor :label, :name, :input, :virtual, :validations,
      :collection, :collection_klass, :collection_method, :collection_params,
      :label_method, :value_method, :input_html, :custom_options

    def submit?
      input == SUBMIT
    end

    def label
      @label || name.to_s.humanize
    end

    def input
      @input || 'text_field'
    end

    def virtual
      @virtual.nil? ? true : @virtual
    end

    def input_html
      @input_html || {}
    end

    def validations
      @validations || {}
    end

    def custom_options
      @custom_options || {}
    end

    def build_validations
      validations
    end

    def label_method
      @label_method || :name
    end

    def value_method
      @value_method || :id
    end

    def build_collection(bind)
      return collection if collection.present?

      Neewom::Collection.build_for_field(self, bind)
    end
  end
end
