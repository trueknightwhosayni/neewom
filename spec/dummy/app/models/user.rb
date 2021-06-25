class User < ApplicationRecord
  include Neewom::Model

  has_neewom_attributes :data

  def self.all_with_neewom(form)
    all.map { |user| user.neewom(form) }
  end
end
