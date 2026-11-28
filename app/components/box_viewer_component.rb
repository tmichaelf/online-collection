# An interactive 3D model of a title's box, built from its six photos.
# Falls back to the front photo where JavaScript or WebGL isn't available.
class BoxViewerComponent < ApplicationComponent
  def initialize(title:)
    @title = title
  end

  def render?
    @title.front_image.attached?
  end

  private
    attr_reader :title

    def textures
      title.attached_faces.index_with { |face| helpers.url_for(title.face_image(face).variant(:display)) }
    end

    def dimensions
      title.box_dimensions
    end

    def views
      %w[ front back left right top bottom ].map { |face| [ face, Title.face_label(face) ] }
    end
end
