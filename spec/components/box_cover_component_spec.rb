require "rails_helper"

RSpec.describe BoxCoverComponent, type: :component do
  it "shows the front photo when there is one" do
    title = create(:title, name: "SimCity 2000", front_image: Rack::Test::UploadedFile.new(file_fixture("front.png"), "image/png"))
    render_inline(described_class.new(title: title))
    expect(page).to have_css("img.box-cover[alt='Front of the SimCity 2000 box']")
  end

  it "shows a placeholder without a front photo" do
    render_inline(described_class.new(title: build(:title, name: "SimCity 2000")))
    expect(page).to have_css(".box-cover--placeholder", text: "S")
  end
end
