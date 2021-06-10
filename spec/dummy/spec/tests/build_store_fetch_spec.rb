require 'rails_helper'

RSpec.describe 'Build -> Store -> Fetch spec' do
  it 'should be serializable' do
    abstract_form = Neewom::AbstractForm.build({
      id: :my_form,
      template: 'custom_form',
      repository_klass: 'User',
      persist_submit_controls: true,
      fields: {
        first_field: {
          label: 'First field',
          input: 'text_field',
          virtual: false,
          validations: {uniqueness: {scope: :aaa}},
          collection_klass: 'SomeClass',
          collection_method: 'some_method',
          collection_params: [:current_user],
          label_method: 'some_method',
          value_method: :some_value_method,
          input_html: {style: 'color: red', data: {id: 'some-id'}},
          custom_options: {some_option: 'a'}
        },
        second_field: {
          label: 'Second field',
          input: 'text_area',
          virtual: true,
          validations: {uniqueness: {scope: :aaa}},
          collection_klass: 'SomeClass',
          collection_method: 'some_method',
          collection_params: [:current_user],
          label_method: 'some_method',
          value_method: :some_value_method,
          input_html: {style: 'color: red', data: {id: 'some-id'}},
          custom_options: {some_option: 'b'}
        }
      }
    }) 
    
    abstract_form.store!

    form_record = Neewom::CustomForm.last

    restored_form = form_record.to_form

    expect(abstract_form.id).to eq restored_form.id.to_sym
    expect(abstract_form.repository_klass).to eq restored_form.repository_klass
    expect(abstract_form.template).to eq restored_form.template
    
    expect(abstract_form.persist_submit_controls).to eq true
    expect(restored_form.persist_submit_controls).to eq true

    first_field = restored_form.fields.find { |f| f.name == 'first_field' }
    second_field = restored_form.fields.find { |f| f.name == 'second_field' }

    expect(first_field.label).to eq 'First field'
    expect(first_field.input).to eq 'text_field'
    expect(first_field.virtual).to eq false
    expect(first_field.validations).to eq({uniqueness: {scope: "aaa"}})
    expect(first_field.collection_klass).to eq 'SomeClass'
    expect(first_field.collection_method).to eq 'some_method'
    expect(first_field.collection_params).to eq [:current_user]
    expect(first_field.label_method).to eq 'some_method'
    expect(first_field.value_method).to eq 'some_value_method'
    expect(first_field.input_html).to eq({style: 'color: red', data: {id: 'some-id'}})
    expect(first_field.custom_options).to eq({some_option: 'a'})

    expect(second_field.label).to eq 'Second field'
    expect(second_field.input).to eq 'text_area'
    expect(second_field.virtual).to eq true
    expect(second_field.validations).to eq({uniqueness: {scope: "aaa"}})
    expect(second_field.collection_klass).to eq 'SomeClass'
    expect(second_field.collection_method).to eq 'some_method'
    expect(second_field.collection_params).to eq [:current_user]
    expect(second_field.label_method).to eq 'some_method'
    expect(second_field.value_method).to eq 'some_value_method'
    expect(second_field.input_html).to eq({style: 'color: red', data: {id: 'some-id'}})
    expect(second_field.custom_options).to eq({some_option: 'b'})

    new_field = Neewom::AbstractField.new
    new_field.name = 'third_field'
    
    restored_form.fields.shift
    restored_form.fields << new_field

    restored_form.store!

    form_record = Neewom::CustomForm.last

    restored_form = form_record.to_form

    third_field = restored_form.fields.find { |f| f.name == 'third_field' }  

    expect(third_field.label).to eq 'Third field'
    expect(third_field.input).to eq 'text_field'
    expect(third_field.virtual).to eq true
    expect(third_field.validations).to eq({})
    expect(third_field.collection_klass).to eq nil
    expect(third_field.collection_method).to eq nil
    expect(third_field.collection_params).to eq nil
    expect(third_field.label_method).to eq "name"
    expect(third_field.value_method).to eq "id"
    expect(third_field.input_html).to eq({})

    missing_field = restored_form.fields.find { |f| f.name == 'first_field' }
    expect(missing_field).to eq nil
  end  
end  

