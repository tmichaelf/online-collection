class Admin::DashboardController < Admin::BaseController
  def show
    @title_count = Title.count
    @user_count = User.count
    @titles_missing_photos = Title.alphabetical.with_attached_faces.select { |title| title.missing_faces.any? }
  end
end
