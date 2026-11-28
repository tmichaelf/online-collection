require "rails_helper"

RSpec.describe Title::BoxFaces, type: :model do
  def image_upload(name, content_type: "image/png")
    Rack::Test::UploadedFile.new(file_fixture(name), content_type)
  end

  it "has an attachment for each of the six sides" do
    expect(Title::FACES).to eq(%w[ front back top bottom left right ])
    Title::FACES.each do |face|
      expect(Title.new.face_image(face)).to be_a(ActiveStorage::Attached::One)
    end
  end

  it "labels the side faces" do
    expect(Title.face_label("left")).to eq("Left side")
    expect(Title.face_label("front")).to eq("Front")
  end

  it "tracks which faces are attached and missing" do
    title = create(:title, front_image: image_upload("front.png"), left_image: image_upload("side.png"))
    expect(title.attached_faces).to eq(%w[ front left ])
    expect(title.missing_faces).to eq(%w[ back top bottom right ])
  end

  describe "validation" do
    it "accepts JPEG, PNG and WebP images" do
      expect(build(:title, front_image: image_upload("front.png"))).to be_valid
    end

    it "rejects files that aren't images" do
      title = build(:title, back_image: image_upload("notes.txt", content_type: "text/plain"))
      expect(title).not_to be_valid
      expect(title.errors[:back_image]).to include("must be a JPEG, PNG or WebP image")
    end

    it "rejects files over the size limit" do
      stub_const("Title::BoxFaces::MAX_FILE_SIZE", 1.kilobyte)
      title = build(:title, front_image: image_upload("front.png"))
      expect(title).not_to be_valid
      expect(title.errors[:front_image]).to include("must be smaller than 0 MB")
    end
  end

  describe "#box_dimensions" do
    it "uses measurements when all three are entered" do
      title = build(:title, box_width_mm: 235, box_height_mm: 290, box_depth_mm: 70)
      expect(title.box_dimensions).to eq(width: 235, height: 290, depth: 70)
    end

    it "works out the depth from the front and side photos" do
      title = create(:title, front_image: image_upload("front.png"), left_image: image_upload("side.png"))
      title.front_image.analyze
      title.left_image.analyze

      expect(title.box_dimensions).to eq(width: 460, height: 580, depth: 120)
    end

    it "falls back to typical big box proportions" do
      expect(build(:title).box_dimensions).to eq(Title::DEFAULT_DIMENSIONS)
    end
  end
end
