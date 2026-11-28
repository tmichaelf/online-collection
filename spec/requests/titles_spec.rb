require "rails_helper"

RSpec.describe "Titles", type: :request do
  before do
    create(:title, name: "Ultima VII", publisher: "Origin Systems", genre: "RPG")
    create(:title, name: "SimCity 2000", publisher: "Maxis", genre: "Simulation")
  end

  it "searches titles" do
    get titles_path, params: { q: "ultim" }
    expect(response.body).to include("Ultima VII")
    expect(response.body).not_to include("SimCity 2000</h3>")
    expect(response.body).to include("1 title")
  end

  it "filters titles and keeps the chosen filter selected" do
    get titles_path, params: { publisher: "Maxis" }
    expect(response.body).to include("SimCity 2000")
    expect(response.body).not_to include("Ultima VII</h3>")
    expect(response.body).to include('<option selected="selected" value="Maxis">Maxis</option>')
  end

  it "says when nothing matches" do
    get titles_path, params: { q: "zork" }
    expect(response.body).to include("No titles match those filters.")
  end

  it "pages through titles" do
    stub_const("Pagination::PER_PAGE", 1)
    get titles_path, params: { genre: "", page: 2 }
    expect(response.body).to include("Page 2 of 2")
    expect(response.body).to include("SimCity 2000").or include("Ultima VII")
  end

  it "shows the 3D viewer on a title with a front photo" do
    title = create(:title, front_image: fixture_file_upload("front.png", "image/png"))
    get title_path(title)
    expect(response.body).to include('data-controller="box-viewer"')
  end
end
