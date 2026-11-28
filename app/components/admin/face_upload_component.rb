class Admin::FaceUploadComponent < ApplicationComponent
  def initialize(form:, face:)
    @form = form
    @face = face
  end

  private
    attr_reader :form, :face

    def title
      form.object
    end

    def attribute
      Title.face_attribute(face)
    end

    def label
      Title.face_label(face)
    end

    def image
      title.face_image(face)
    end

    def saved_image?
      image.attached? && image.blob.persisted? && title.persisted?
    end

    def errors
      title.errors.full_messages_for(attribute)
    end

    def accept
      Title::CONTENT_TYPES.join(",")
    end
end
