class CollectionItem < ApplicationRecord
  belongs_to :user
  belongs_to :title

  enum :condition, {
    sealed: "sealed",
    complete: "complete",
    incomplete: "incomplete",
    box_only: "box_only"
  }, validate: true

  validates :title_id, uniqueness: { scope: :user_id, message: "is already in this collection" }

  scope :by_title_name, -> { joins(:title).order("titles.name") }
end
