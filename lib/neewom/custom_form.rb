module Neewom
  class CustomForm < ActiveRecord::Base
    self.table_name = 'neewom_forms'

    has_many :custom_fields, -> { order(order: :asc) }, foreign_key: :form_id

    validates :key, :repository_klass, :template, presence: true
    validates :description, length: {minimum: 3, maximum: 255}, allow_blank: true

    def to_form
      Neewom::Repository.new.fetch!(self)
    end
  end
end