class Title < ApplicationRecord
  has_many :collection_items, dependent: :restrict_with_error
  has_many :collectors, through: :collection_items, source: :user

  validates :name, presence: true
  validates :release_year, numericality: { only_integer: true, in: 1970..2100 }, allow_nil: true

  scope :alphabetical, -> { order(:name) }

  def to_param
    [ id, name.parameterize ].join("-")
  end
end
