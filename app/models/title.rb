class Title < ApplicationRecord
  include BoxFaces, Searchable

  has_many :collection_items, dependent: :restrict_with_error
  has_many :collectors, through: :collection_items, source: :user

  validates :name, presence: true
  validates :release_year, numericality: { only_integer: true, in: 1970..2100 }, allow_nil: true
  validates :box_width_mm, :box_height_mm, :box_depth_mm, numericality: { only_integer: true, in: 10..1000 }, allow_nil: true

  scope :alphabetical, -> { order(:name) }

  def to_param
    [ id, name.parameterize ].join("-")
  end
end
