require "rails_helper"

RSpec.describe "Public pages", type: :request do
  let!(:demo) { create(:user, username: Rails.configuration.x.demo_collector) }
  let!(:item) { create(:collection_item, user: demo, title: create(:title, name: "Wing Commander")) }

  it "shows the demo collection on the home page without signing in" do
    get root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Wing Commander")
  end

  it "shows any collector's page without signing in" do
    get collector_path(demo)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Wing Commander")
  end

  it "lists collectors and titles without signing in" do
    get collectors_path
    expect(response.body).to include(demo.username)

    get titles_path
    expect(response.body).to include("Wing Commander")

    get title_path(item.title)
    expect(response).to have_http_status(:ok)
  end

  it "returns not found for an unknown collector" do
    get collector_path("nobody")
    expect(response).to have_http_status(:not_found)
  end
end
