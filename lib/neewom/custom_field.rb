module Neewom
  class CustomField < ActiveRecord::Base
    self.table_name = 'neewom_fields'

    belongs_to :custom_form, foreign_key: :form_id

    validates :name, presence: true
    validates :input, inclusion: { in: Neewom::AbstractField::SUPPORTED_FIELDS }
  end
end