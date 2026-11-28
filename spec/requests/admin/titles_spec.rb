require "rails_helper"

RSpec.describe "Admin titles", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:front) { fixture_file_upload("front.png", "image/png") }

  it "is closed to collectors who aren't admins" do
    sign_in_as create(:user)
    get admin_titles_path
    expect(response).to redirect_to(root_path)

    post admin_titles_path, params: { title: { name: "Sneaky" } }
    expect(Title.exists?(name: "Sneaky")).to be(false)
  end

  context "as an admin" do
    before { sign_in_as admin }

    it "lists titles with how many photos each has" do
      create(:title, name: "Wing Commander", front_image: front)
      get admin_titles_path
      expect(response.body).to include("Wing Commander")
      expect(response.body).to include("1 of 6")
      expect(response.body).to include(%(action="/admin/titles/#{Title.last.to_param}"))
    end

    it "creates a title with box photos" do
      expect {
        post admin_titles_path, params: { title: { name: "Ultima VII", release_year: 1992, front_image: front, left_image: fixture_file_upload("side.png", "image/png") } }
      }.to change(Title, :count).by(1)

      title = Title.last
      expect(response).to redirect_to(edit_admin_title_path(title))
      expect(title.attached_faces).to eq(%w[ front left ])
    end

    it "queues the image variants for processing in the background" do
      expect {
        post admin_titles_path, params: { title: { name: "Ultima VII", front_image: front } }
      }.to have_enqueued_job(ActiveStorage::TransformJob).at_least(:once)
    end

    it "shows errors when the title can't be saved" do
      post admin_titles_path, params: { title: { name: "", back_image: fixture_file_upload("notes.txt", "text/plain") } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Name can&#39;t be blank")
      expect(response.body).to include("must be a JPEG, PNG or WebP image")
    end

    it "updates details and adds photos without removing existing ones" do
      title = create(:title, front_image: front)
      patch admin_title_path(title), params: { title: { genre: "Adventure", back_image: fixture_file_upload("front.png", "image/png") } }

      expect(title.reload.genre).to eq("Adventure")
      expect(title.attached_faces).to eq(%w[ front back ])
    end

    it "removes a single photo" do
      title = create(:title, front_image: front)
      delete admin_title_face_path(title, "front")

      expect(response).to redirect_to(edit_admin_title_path(title))
      perform_enqueued_jobs
      expect(title.reload.front_image).not_to be_attached
    end

    it "returns not found for an unknown face" do
      title = create(:title)
      delete admin_title_face_path(title, "inside")
      expect(response).to have_http_status(:not_found)
    end

    it "deletes a title that nobody collects" do
      title = create(:title)
      expect { delete admin_title_path(title) }.to change(Title, :count).by(-1)
    end

    it "keeps a title that is in someone's collection" do
      item = create(:collection_item)
      expect { delete admin_title_path(item.title) }.not_to change(Title, :count)
      expect(flash[:alert]).to be_present
    end
  end
end
