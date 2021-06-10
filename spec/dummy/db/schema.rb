# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_06_10_130113) do

  create_table "neewom_fields", force: :cascade do |t|
    t.integer "form_id", null: false
    t.string "label"
    t.string "name", null: false
    t.string "input"
    t.boolean "virtual"
    t.string "validations"
    t.string "collection_klass"
    t.string "collection_method"
    t.string "collection_params"
    t.string "label_method"
    t.string "value_method"
    t.string "input_html"
    t.string "custom_options"
    t.integer "order", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["form_id", "name"], name: "index_neewom_fields_on_form_id_and_name", unique: true
  end

  create_table "neewom_forms", force: :cascade do |t|
    t.string "key", null: false
    t.string "description"
    t.string "crc32", null: false
    t.string "repository_klass", null: false
    t.string "template", null: false
    t.boolean "persist_submit_controls"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["crc32"], name: "index_neewom_forms_on_crc32", unique: true
    t.index ["key"], name: "index_neewom_forms_on_key", unique: true
  end

end
