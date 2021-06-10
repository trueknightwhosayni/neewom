class CustomController < ApplicationController
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

  private

  def permitted_params
    params.require(form.strong_params_require).permit(form.strong_params_permit)
  end

  def form_url
    custom_index_path
  end
  helper_method :form_url

  def form_method
    :post
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
