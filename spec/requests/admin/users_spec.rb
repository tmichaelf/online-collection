require "rails_helper"

RSpec.describe "Admin users", type: :request do
  let(:admin) { create(:user, :admin, username: "michael") }
  let!(:collector) { create(:user, username: "tentaclefan") }

  it "is closed to collectors who aren't admins" do
    sign_in_as collector
    get admin_users_path
    expect(response).to redirect_to(root_path)

    patch admin_user_path(collector), params: { user: { admin: "1" } }
    expect(collector.reload).not_to be_admin
  end

  context "as an admin" do
    before { sign_in_as admin }

    it "lists users with their role" do
      get admin_users_path
      expect(response.body).to include("tentaclefan")
      expect(response.body).to include("Collector")
      expect(response.body).to include("Admin")
    end

    it "makes another user an admin" do
      patch admin_user_path(collector), params: { user: { admin: "1" } }
      expect(response).to redirect_to(admin_users_path)
      expect(collector.reload).to be_admin
    end

    it "edits a user's details" do
      patch admin_user_path(collector), params: { user: { username: "loomfan", email_address: "loom@example.com" } }
      expect(collector.reload).to have_attributes(username: "loomfan", email_address: "loom@example.com")
    end

    it "shows errors for invalid details" do
      patch admin_user_path(collector), params: { user: { username: "michael" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Username has already been taken")
    end

    it "deletes a user and their collection but keeps the titles" do
      item = create(:collection_item, user: collector)
      expect { delete admin_user_path(collector) }.to change(User, :count).by(-1)
      expect(CollectionItem.exists?(item.id)).to be(false)
      expect(Title.exists?(item.title_id)).to be(true)
    end

    it "won't let an admin remove their own admin access or delete themselves" do
      patch admin_user_path(admin), params: { user: { admin: "0" } }
      expect(admin.reload).to be_admin

      delete admin_user_path(admin)
      expect(User.exists?(admin.id)).to be(true)
      expect(flash[:alert]).to include("can't remove your own admin access")
    end
  end
end
