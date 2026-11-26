require "rails_helper"

RSpec.describe CollectionItem, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:title) }

  it "allows a title only once per collection" do
    item = create(:collection_item)
    duplicate = build(:collection_item, user: item.user, title: item.title)
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:title_id]).to include("is already in this collection")
  end

  it "lets different collectors own the same title" do
    item = create(:collection_item)
    expect(build(:collection_item, title: item.title)).to be_valid
  end

  it "rejects unknown conditions" do
    expect(build(:collection_item, condition: "mint")).not_to be_valid
  end
end
