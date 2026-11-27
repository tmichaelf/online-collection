require "rails_helper"

RSpec.describe "Admin dashboard", type: :request do
  it "sends visitors to sign in" do
    get admin_root_path
    expect(response).to redirect_to(new_session_path)
  end

  it "turns away collectors who aren't admins" do
    sign_in_as create(:user)
    get admin_root_path
    expect(response).to redirect_to(root_path)
  end

  it "lets admins in" do
    sign_in_as create(:user, :admin)
    get admin_root_path
    expect(response).to have_http_status(:ok)
  end
end
