class Admin::TitlesController < Admin::BaseController
  before_action :set_title, only: %i[ edit update destroy ]

  def index
    @titles = Title.alphabetical.with_attached_faces
  end

  def new
    @title = Title.new
  end

  def create
    @title = Title.new(title_params)

    if @title.save
      redirect_to edit_admin_title_path(@title), notice: "Title created. Add any missing box photos below."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @title.update(title_params)
      redirect_to edit_admin_title_path(@title), notice: "Title saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @title.destroy
      redirect_to admin_titles_path, notice: "#{@title.name} was deleted.", status: :see_other
    else
      redirect_to edit_admin_title_path(@title), alert: @title.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    def set_title
      @title = Title.find(params.expect(:id))
    end

    def title_params
      params.expect(title: [
        :name, :publisher, :developer, :release_year, :genre, :platform, :description,
        :box_width_mm, :box_height_mm, :box_depth_mm,
        *Title::FACES.map { |face| Title.face_attribute(face) }
      ])
    end
end
