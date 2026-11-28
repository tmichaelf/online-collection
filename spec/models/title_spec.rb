require "rails_helper"

RSpec.describe Title, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_numericality_of(:release_year).only_integer.is_in(1970..2100).allow_nil }
  it { is_expected.to have_many(:collectors).through(:collection_items) }
  it { is_expected.to validate_numericality_of(:box_depth_mm).only_integer.is_in(10..1000).allow_nil }

  it "uses the id and a slug of the name in URLs" do
    title = create(:title, name: "Ultima VII: The Black Gate")
    expect(title.to_param).to eq("#{title.id}-ultima-vii-the-black-gate")
  end

  it "can't be deleted while it is in a collection" do
    item = create(:collection_item)
    expect(item.title.destroy).to be(false)
    expect(item.title.errors[:base]).to be_present
  end
end
