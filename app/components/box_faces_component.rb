class BoxFacesComponent < ApplicationComponent
  def initialize(title:)
    @title = title
  end

  def render?
    @title.attached_faces.any?
  end

  private
    def faces
      @title.attached_faces.map { |face| [ Title.face_label(face), @title.face_image(face) ] }
    end
end
