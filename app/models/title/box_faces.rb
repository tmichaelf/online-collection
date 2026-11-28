# The six scanned sides of a title's box, and the box proportions worked out from them.
module Title::BoxFaces
  extend ActiveSupport::Concern

  FACES = %w[ front back top bottom left right ].freeze
  CONTENT_TYPES = %w[ image/jpeg image/png image/webp ].freeze
  MAX_FILE_SIZE = 40.megabytes

  # Typical big box proportions, used until there are photos or measurements to go on.
  DEFAULT_DIMENSIONS = { width: 230, height: 290, depth: 60 }.freeze

  included do
    FACES.each do |face|
      has_one_attached :"#{face}_image" do |attachable|
        attachable.variant :thumb, resize_to_limit: [ 320, 320 ], format: :webp, preprocessed: true
        attachable.variant :display, resize_to_limit: [ 1600, 1600 ], format: :webp, preprocessed: true
      end
    end

    validate :box_face_images_are_acceptable

    scope :with_attached_faces, -> { includes(FACES.map { |face| { "#{face}_image_attachment": :blob } }) }
  end

  class_methods do
    def face_attribute(face)
      :"#{face}_image"
    end

    def face_label(face)
      { "left" => "Left side", "right" => "Right side" }.fetch(face, face.capitalize)
    end
  end

  def face_image(face)
    public_send(self.class.face_attribute(face))
  end

  def attached_faces
    FACES.select { |face| face_image(face).attached? }
  end

  def missing_faces
    FACES - attached_faces
  end

  # Box size in millimetres when measured, otherwise proportions derived from the
  # front and side photos, otherwise typical big box proportions.
  def box_dimensions
    measured_dimensions || photographed_dimensions || DEFAULT_DIMENSIONS
  end

  private
    def measured_dimensions
      return unless box_width_mm && box_height_mm && box_depth_mm

      { width: box_width_mm, height: box_height_mm, depth: box_depth_mm }
    end

    def photographed_dimensions
      front = image_size(front_image)
      return unless front

      side = image_size(left_image) || image_size(right_image)
      depth = side ? (side[:width] * front[:height].to_f / side[:height]).round : (front[:height] * DEFAULT_DIMENSIONS[:depth].to_f / DEFAULT_DIMENSIONS[:height]).round

      { width: front[:width], height: front[:height], depth: depth }
    end

    def image_size(image)
      return unless image.attached? && image.blob.analyzed?

      width, height = image.blob.metadata.values_at("width", "height")
      { width: width, height: height } if width.to_i.positive? && height.to_i.positive?
    end

    def box_face_images_are_acceptable
      FACES.each do |face|
        attribute = self.class.face_attribute(face)
        image = face_image(face)
        next unless image.attached? && attachment_changes.key?(attribute.to_s)

        errors.add(attribute, "must be a JPEG, PNG or WebP image") unless image.blob.content_type.in?(CONTENT_TYPES)
        errors.add(attribute, "must be smaller than #{MAX_FILE_SIZE / 1.megabyte} MB") if image.blob.byte_size > MAX_FILE_SIZE
      end
    end
end
