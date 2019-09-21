module Neewom
  module Proxies
    module BuildersAndFinders
      def build_resource(controller_params=nil, initial_values: {})
        resource = repository_klass.constantize.new
        apply_inputs(resource, controller_params, initial_values: initial_values)
      end
  
      def apply_inputs(resource, controller_params, initial_values: {})
        return unless resource.present?

        resource.initialize_neewom_attributes(self) if resource.respond_to?(:initialize_neewom_attributes)        

        if controller_params.present?
          params = permit_params(controller_params)

          initial_values.each do |field, value|
            if resource.respond_to?(:"#{field}=")
              resource.public_send(:"#{field}=", value)
            else
              raise "The form trying to setup the #{field} field from an initial data, but the #{resource.class.name} can't accept it"
            end
          end

          data = persisted_fields.each_with_object({}) do |field, acc| 
            acc[field.name.to_sym] = params[field.name.to_sym] if params.has_key?(field.name.to_sym) 
          end

          resource.assign_attributes(data) 
        end
  
        resource
      end  

      def parse_submit_control_value(controller_params)
        submit_fields.each_with_object({}) do |field, acc| 
          acc[field.name.to_sym] = controller_params[field.name.to_sym] if controller_params.has_key?(field.name.to_sym)
        end
      end
      
      def find(id)
        resource = repository_klass.constantize.find(id)
        resource.initialize_neewom_attributes(self)
  
        resource
      end
  
      def find_by(options)
        resource = repository_klass.constantize.find_by(options)
        resource.initialize_neewom_attributes(self) if resource.present?
  
        resource
      end
  
      def find_by!(options)
        resource = repository_klass.constantize.find_by!(options)
        resource.initialize_neewom_attributes(self)
  
        resource
      end

      def find_and_apply_inputs(id, form_params, initial_values: {})
        apply_inputs(find(id), form_params, initial_values: initial_values)
      end

      def find_by_and_apply_inputs(options, form_params, initial_values: {})
        apply_inputs(find_by(options), form_params, initial_values: initial_values)
      end

      def find_by_and_apply_inputs!(options, form_params, initial_values: {})
        apply_inputs(find_by!(options), form_params, initial_values: initial_values)
      end

      def permit_params(controller_params)
        controller_params.require(strong_params_require).permit(strong_params_permit)
      end

      def strong_params_require
        repository_klass.constantize.model_name.param_key.to_sym
      end
  
      def strong_params_permit
        fields.map(&:name)
      end
    end
  end
end  