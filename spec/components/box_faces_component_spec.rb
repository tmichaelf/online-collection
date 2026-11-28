require "rails_helper"

RSpec.describe BoxFacesComponent, type: :component do
  it "shows each attached face with its label" do
    title = create(:title, front_image: Rack::Test::UploadedFile.new(file_fixture("front.png"), "image/png"),
                           right_image: Rack::Test::UploadedFile.new(file_fixture("side.png"), "image/png"))
    render_inline(described_class.new(title: title))
    expect(page).to have_css("figcaption", text: "Front")
    expect(page).to have_css("figcaption", text: "Right side")
    expect(page).to have_css("figure", count: 2)
  end

  it "renders nothing without photos" do
    render_inline(described_class.new(title: build(:title)))
    expect(page).not_to have_css(".box-faces")
  end
end
