require 'rails_helper'

RSpec.describe 'Serializer spec' do
  it 'should be serializable' do
    abstract_form = Neewom::AbstractForm.build({
      id: :my_form,
      template: 'custom_form',
      repository_klass: 'User',
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
    
    result = abstract_form.to_h

    # no virtual in results
    expect(result).to eq({
      id: :my_form,
      template: 'custom_form',
      repository_klass: 'User',
      fields: {
        first_field: {
          label: 'First field',
          input: 'text_field',
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
  end  
end  

