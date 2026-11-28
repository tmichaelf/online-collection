require "rails_helper"

RSpec.describe Admin::FaceUploadComponent, type: :component do
  def render_for(title, face)
    with_request_url "/admin/titles/new" do
      vc_test_controller.view_context.form_with(model: [ :admin, title ]) do |form|
        render_inline(described_class.new(form: form, face: face))
      end
    end
  end

  it "renders a drop zone with a direct upload file field" do
    render_for(build(:title), "left")
    expect(page).to have_css("[data-controller='face-upload']")
    expect(page).to have_field("Left side", type: "file")
    expect(page).to have_css("input[type=file][data-direct-upload-url][accept='image/jpeg,image/png,image/webp']")
    expect(page).not_to have_link("Remove photo")
  end

  it "shows the saved photo with a remove link" do
    title = create(:title, front_image: Rack::Test::UploadedFile.new(file_fixture("front.png"), "image/png"))
    render_for(title, "front")
    expect(page).to have_css("img[alt='Front of the box']")
    expect(page).to have_link("Remove photo")
  end

  it "shows validation errors for the face" do
    title = build(:title)
    title.errors.add(:top_image, "must be a JPEG, PNG or WebP image")
    render_for(title, "top")
    expect(page).to have_css(".face-upload--invalid")
    expect(page).to have_text("Top image must be a JPEG, PNG or WebP image")
  end
end
