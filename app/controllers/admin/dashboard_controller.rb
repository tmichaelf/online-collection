class Admin::DashboardController < Admin::BaseController
  def show
    @title_count = Title.count
    @user_count = User.count
  end
end
