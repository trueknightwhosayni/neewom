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
