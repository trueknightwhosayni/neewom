class CreateNeewomTables < ActiveRecord::Migration[6.0]
  def change
    create_table :neewom_forms do |t|
      t.string :key, null: false, index: { unique: true }
      t.string :description
      t.string :crc32, null: false, index: { unique: true }
      t.string :repository_klass, null: false
      t.string :template, null: false
      t.boolean :persist_submit_controls, default: false

      t.timestamps null: false
    end

    create_table :neewom_fields do |t|
      t.integer :form_id, null: false
      t.integer :order, null: false, default: 0
      t.string  :label
      t.string  :name, null: false
      t.string  :input
      t.boolean :virtual
      t.string  :validations
      t.string  :collection_klass
      t.string  :collection_method
      t.string  :collection_params
      t.string  :label_method
      t.string  :value_method
      t.string  :input_html
      t.string  :custom_options

      t.timestamps null: false
    end

    add_index :neewom_fields, [:form_id, :name], unique: true
  end
end
