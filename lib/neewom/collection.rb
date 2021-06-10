module Neewom
  class Collection
    SEQ_KEY = "neewom|value|"
    MOD_KEY = "|mods:"

    def self.build_for_field(field, bind)
      method_params = field.collection_params.map do |param|
        if param.start_with?(SEQ_KEY)
          deserialize(param)
        else
          eval param.to_s, bind
        end
      end

      field.collection_klass.constantize.public_send(field.collection_method, *method_params)
    end

    def self.deserialize(param)
      token = param.gsub(SEQ_KEY, "")

      value, mods = token.split(MOD_KEY)
      value = JSON.parse(value)

      value = mods.split('.').reduce(value) { |acc, mod| acc.public_send(mod) } if mods.present?

      value
    end

    def self.serialize(value, mods="")
      token = "#{SEQ_KEY}#{value.to_json}"
      token += "#{MOD_KEY}#{mods}" unless mods.blank?

      token
    end
  end
end
