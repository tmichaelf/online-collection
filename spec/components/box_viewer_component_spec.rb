require "rails_helper"

RSpec.describe BoxViewerComponent, type: :component do
  def upload(name)
    Rack::Test::UploadedFile.new(file_fixture(name), "image/png")
  end

  it "passes the box photos and dimensions to the viewer" do
    title = create(:title, name: "Loom", front_image: upload("front.png"), left_image: upload("side.png"), box_width_mm: 230, box_height_mm: 290, box_depth_mm: 60)
    render_inline(described_class.new(title: title))

    viewer = page.find("[data-controller='box-viewer']")
    textures = JSON.parse(viewer["data-box-viewer-textures-value"])
    expect(textures.keys).to eq(%w[ front left ])
    expect(textures.values).to all(include("/rails/active_storage/representations/"))
    expect(JSON.parse(viewer["data-box-viewer-dimensions-value"])).to eq("width" => 230, "height" => 290, "depth" => 60)
  end

  it "shows the front photo until the 3D view loads" do
    title = create(:title, name: "Loom", front_image: upload("front.png"))
    render_inline(described_class.new(title: title))
    expect(page).to have_css("img.box-cover[alt='Front of the Loom box']")
    expect(page).to have_css(".box-viewer__toolbar[hidden]", visible: :all)
  end

  it "offers a button for each side" do
    title = create(:title, front_image: upload("front.png"))
    render_inline(described_class.new(title: title))
    %w[ Front Back Left\ side Right\ side Top Bottom Reset Spin Full\ screen ].each do |label|
      expect(page).to have_button(label, visible: :all)
    end
  end

  it "renders nothing without a front photo" do
    render_inline(described_class.new(title: build(:title)))
    expect(page).not_to have_css(".box-viewer")
  end
end
