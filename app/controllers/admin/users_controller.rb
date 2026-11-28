class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: %i[ edit update destroy ]
  before_action :protect_current_admin, only: %i[ update destroy ]

  def index
    @users = User.order(:username).includes(:collection_items)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "#{@user.username} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: "#{@user.username} and their collection were deleted.", status: :see_other
  end

  private
    def set_user
      @user = User.find_by!(username: params.expect(:id))
    end

    def user_params
      params.expect(user: %i[ username email_address admin ])
    end

    # Admins manage their own account elsewhere, so they can't lock themselves out here.
    def protect_current_admin
      if @user == Current.user && (action_name == "destroy" || user_params[:admin] == "0")
        redirect_to admin_users_path, alert: "You can't remove your own admin access or delete your own account here.", status: :see_other
      end
    end
end
