class Admin::Titles::FacesController < Admin::BaseController
  def destroy
    title = Title.find(params.expect(:title_id))
    face = Title::FACES.find { |name| name == params[:face] } or raise ActiveRecord::RecordNotFound

    title.face_image(face).purge_later
    redirect_to edit_admin_title_path(title), notice: "Removed the #{face} photo.", status: :see_other
  end
end
