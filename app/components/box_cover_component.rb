class BoxCoverComponent < ApplicationComponent
  def initialize(title:, variant: :thumb)
    @title = title
    @variant = variant
  end

  def call
    if @title.front_image.attached?
      image_tag @title.front_image.variant(@variant), alt: "Front of the #{@title.name} box", class: "box-cover", loading: "lazy"
    else
      tag.div @title.name.first, class: "box-cover box-cover--placeholder", aria: { hidden: true }
    end
  end
end
