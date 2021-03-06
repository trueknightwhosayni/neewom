# Neewom

Rails custom form builder. Was designed to solve general issues about dynamic attributes:

 - Ability to have different fields on the same form for different users
 - Ability to allow your users to add a custom fields on forms they need
 - Ability to search by custom data.

 # Custom fields for different users.

 Before building a custom attributes system (which is usually takes about 60 hours), developers goes by a simple way and just add new column to the database.
 It's a common use case, when some customer is ready to pay for  your service, but if you will add some specific fields on some forms. And often other users doesn't need those fields.

 This approach still a good one and the most simplest and cheapest. But, with growing a number of users, who needs their own custom fields, it becomes a pain.

 Neewom is a flexible solution which allows to organize your custom forms.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'neewom'
```

Copy a default form template

**app/views/neewom_forms/form.html.erb**

```ruby
<%= form_for @resource, url: form_url, method: form_method do |f| %>
  <% form.fields.each do |field| %>
    <div>
      <% unless field.input == Neewom::AbstractField::SUBMIT %>
        <%= f.label field.name, field.label %>
      <% end %>
      <% case field.input %>
      <% when Neewom::AbstractField::EMAIL %>
        <%= f.email_field field.name, field.input_html %>
      <% when Neewom::AbstractField::HIDDEN %>
        <%= f.hidden_field field.name, field.input_html %>
      <% when Neewom::AbstractField::NUMBER %>
        <%= f.number_field field.name, field.input_html %>
      <% when Neewom::AbstractField::PASSWORD %>
        <%= f.password_field field.name, field.input_html %>
      <% when Neewom::AbstractField::PHONE %>
        <%= f.phone_field field.name, field.input_html %>
      <% when Neewom::AbstractField::SELECT %>
        <%
          options = []
          collection = field.build_collection(binding)

          if collection.any?
            if collection.first.is_a?(Array)
              options = collection
            else
              options = collection.map { |i| [i.public_send(field.label_method), i.public_send(field.value_method)] }
            end
          end
        %>

        <%= f.select field.name, options, field.input_html %>
      <% when Neewom::AbstractField::SUBMIT %>
        <%= f.submit field.label, {name: field.name}.merge(field.input_html) %>
      <% when Neewom::AbstractField::TEXTAREA %>
        <%= f.text_area field.name, field.input_html %>
      <% when Neewom::AbstractField::TEXT %>
        <%= f.text_field field.name, field.input_html %>
      <% end %>
      <% if @resource.errors[field.name].any? %>
        <span class="errors"><%= @resource.errors[field.name].join(', ')%></span>
      <% end %>
    </div>
  <% end %>
<% end %>
```

## Usage

Add a jsonb field, which will store the custom attributes

```ruby
class AddAttributesToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :data, :jsonb
  end
end
```

Configure your model to work with that field

```ruby
class User < ApplicationRecord
  include Neewom::Model

  has_neewom_attributes :data
end
```

Next you need to describe the form. Please note, that by default you need to describe all fields, not just a custom ones. But, you can generate another template and predefine some fields there.

```ruby
Neewom::AbstractForm.build(
  id: :custom_user_form,
  repository_klass: 'User',
  fields: {
    name: {
      virtual: true
    },
    email: {
      virtual: false,
      input: 'email_field'
    },
    password: {
      virtual: false,
      input: 'password_field',
      validations: {presence: true, confirmation: true}
    },
    password_confirmation: {
      virtual: false,
      input: 'password_field'
    },
    commit: {
      label: 'Save',
      input: 'submit'
    }
  }
)
```

### Form attributes

1. **id** (*required*) - An unique form id
2. **repository_klass** (*required*) - An active record model name with configured neewom attributes
3. **fields** (*required*) - A hash with fields config.
4. **template** - form template name ("form" by default)
5. **persist_submit_controls** - flag for controling submit button persistance. Need if your submit not just a button, but also a value

### Field attrbutes

The hash keys are also a names.

1. **label** - Input label. By default it's `name.to_s.humanize`
2. **input** - Field input. By default it's 'text_field'. Check the `Neewom::AbstractField::SUPPORTED_FIELDS` to get the list of supported inputs
3. **virtual** - Boolean, true by default. Should be false if you need to store data in a real column instead of the jsonb one
4. **validations** - Array of Hashes, or Hash by default an empty one. Should be the standard rails validations
5. **collection** - Collection of objects for the select input. Can not be stored to the database
6. **label_method** - A label method for collection. Used while building options for select
7. **value_method** - A value method for collection. Used while building options for select. It's 'id' by default
8. **input_html** - A hash with the HTML attributes
9. **custom_options** - A hash to provide any other additional information

Another way to define a collection is to pass three params

1. **collection_klass** - A class which contain the specific logic
2. **collection_method** - A class method of the `collection_class`
3. **collection_params** - A view context methods. Will pass to `collection_method`

So, the `{collection_klass: 'EmployeesCollections', collection_method: 'managers_for_user', collection_params: [:current_user]}` will call the

```ruby
EmployeesCollections.managers_for_user(current_user)
```

inside the view.

## Defining a controller

You need to define the next methods as a helper_methods: `form_url`, `form_method`, `form`

An instance of the `Neewom::AbstractForm` will have a set of usefull methods you need to use in the controller

1. `form.build_resource(permitted_params)` - will build a new ActiveRecord model
2. `form.find(id)`
3. `form.find_by(id: 1)`
4. `form.find_by!(id: 1)`
5. `form.repository_klass.constantize` - get a ActiveRecord model class
6. `form.strong_params_require` - the require part for strong params
7. `form.strong_params_permit` - the permit part for strong params


It's more easy to use an existing methods, because there are an existing neewom initialization inside

```ruby
def build_resource(params)
  resource = repository_klass.constantize.new
  resource.initialize_neewom_attributes(self)
  resource.assign_attributes(params) if params.present?

  resource
end
```

### The complete controller example

```ruby
class UsersController < ApplicationController
  def index
    @collection = User.all.map { |user| user.neewom_view(:name, :role) }
  end

  def new
    @resource = form.build_resource
    render "neewom_forms/#{form.template}"
  end

  def create
    @resource = form.build_resource permitted_params

    if @resource.save
      redirect_to root_path
    else
      render "neewom_forms/#{form.template}"
    end
  end

  def edit
    @resource = form.find(params[:id])

    render "neewom_forms/#{form.template}"
  end

  def update
    @resource = form.find_and_apply_inputs(params[:id], permitted_params)

    if @resource.save
      redirect_to root_path
    else
      render "neewom_forms/#{form.template}"
    end
  end

  def destroy
    @resource = form.find(params[:id])
    @resource.destroy

    redirect_to root_path
  end

  private

  def permitted_params
    params.require(form.strong_params_require).permit(form.strong_params_permit)
  end

  def form_url
    @resource && @resource.persisted? ? user_path(@resource) : users_path
  end
  helper_method :form_url

  def form_method
    @resource && @resource.persisted? ? :patch : :post
  end
  helper_method :form_method

  def form
    @form ||= Neewom::AbstractForm.build(
      id: :custom_user_form,
      repository_klass: 'User',
      fields: {
        name: {
          virtual: true
        },
        role: {
          virtual: true,
          input: 'select_field',
          collection: ['admin', 'quest'].map { |r| [r, r] }
        },
        inviter: {
          virtual: true,
          input: 'select_field',
          collection_klass: 'User',
          collection_method: :all_with_neewom,
          collection_params: [:form]
        },
        manager: {
          virtual: true,
          input: 'select_field',
          collection_klass: 'Managers',
          collection_method: :for_user,
          collection_params: [Neewom::Collection.serialize('EN'), :current_user, "some_helper(current_user)"]
        },
        email: {
          virtual: false,
          input: 'email_field'
        },
        password: {
          virtual: false,
          input: 'password_field',
          validations: [{presence: true, on: :update}, {confirmation: true, allow_blank: true }]
        },
        password_confirmation: {
          virtual: false,
          input: 'password_field'
        },
        commit: {
          label: 'Save',
          input: 'submit'
        }
      }
    )
  end
  helper_method :form
end
```

# Reading fields

To be able to read data from the model you need to define form fields. There are several ways to do this

```ruby
@user = User.first

# in this case you need to specify the virtual fields list
@user = @user.neewom_view(:name, :role, :some_field)

# in this case you need to specify the instance of the Neewom::AbstractForm
form = Neewom::AbstractForm.build(
  id: :custom_user_form,
  repository_klass: 'User',
  fields: {
    name: {
      virtual: true
    },
  }
)
@user = @user.neewom(form)

# in this case you need to specify the instance of the Neewom::CustomForm
form = Neewom::CustomForm.first
@user = @user.neewom(form)

# in this case you need to specify the id of of the stored Neewom::CustomForm
form = Neewom::AbstractForm.build(
  id: :custom_user_form,
  repository_klass: 'User',
  fields: {
    name: {
      virtual: true
    },
  }
)
form.store!
@user = @user.neewom(:custom_user_form)
```


## Validations

Multiple validations example

```ruby
def form
  @form ||= Neewom::AbstractForm.build(
    id: :custom_user_form,
    repository_klass: 'User',
    fields: {
      name: {
        virtual: true,
        validations: [
          {presence: true, on: :update},
          {length: { minimum: 10 }}
        ]
      },
    }
  )
end
helper_method :form
```

## Collections

You can build a field collection within the form object.

```ruby
def form
  @form ||= Neewom::AbstractForm.build(
    id: :custom_user_form,
    repository_klass: 'User',
    fields: {
      name: {
        virtual: true,
        collection: [OpenStruct.new(id: '1', name: 'Dave'), OpenStruct.new(id: '1', name: 'Bruce')]
      },
    }
  )
end
helper_method :form
```

Specifying custom methods also allowed

```ruby
def form
  @form ||= Neewom::AbstractForm.build(
    id: :custom_user_form,
    repository_klass: 'User',
    fields: {
      name: {
        virtual: true,
        collection: [OpenStruct.new(uid: '1', title: 'London'), OpenStruct.new(uid: '1', title: 'Paris')],
        label_method: :title,
        value_method: :uid,
      },
    }
  )
end
helper_method :form
```

Or you can specify the collection builder class

```ruby
def form
  @form ||= Neewom::AbstractForm.build(
    id: :custom_user_form,
    repository_klass: 'User',
    fields: {
      name: {
        virtual: true,
        collection_klass: 'CollectionBuilder',
        collection_method: 'called_method',
        collection_params: [Neewom::Colllection.serialize(42), :current_user, "some_helper(current_user)"],
      },
    }
  )
end
helper_method :form
```

In this example the `called_method` of the `CollectionBuilder` class (**class but not instance!**) will receive the next values:

```ruby
[42, current_user(), some_helper(current_user())]
```

It will use binding with eval under the hood, this is why this things works.

## Custom field inputs

You can push new value into the `Neewom::AbstractField::SUPPORTED_FIELDS` array and then update your view to support new field

## Storing forms in the database.

If you didn't used a `collection` in any field, you can store the form to the database.

Add a neewom tables first

```ruby
def change
  create_table :neewom_forms do |t|
    t.string :key, null: false, index: { unique: true }
    t.string :description
    t.string :crc32, null: false, index: { unique: true }
    t.string :repository_klass, null: false
    t.string :template, null: false
    t.boolean :persist_submit_controls

    t.timestamps null: false
  end

  create_table :neewom_fields do |t|
    t.integer :form_id, null: false
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
    t.integer :order, default: 0

    t.timestamps null: false
  end

  add_index :neewom_fields, [:form_id, :name], unique: true
end
```

Then you can store and fetch forms.

```ruby

form.store!
restored_form = Neewom::CustomForm.find_by!(key: form.id).to_form
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/neewom. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Neewom project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/neewom/blob/master/CODE_OF_CONDUCT.md).
