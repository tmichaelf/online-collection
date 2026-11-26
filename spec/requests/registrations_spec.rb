require "rails_helper"

RSpec.describe "Registrations", type: :request do
  it "creates an account, signs in and opens the new collection" do
    expect {
      post registration_path, params: { user: { username: "newcollector", email_address: "new@example.com", password: "password123", password_confirmation: "password123" } }
    }.to change(User, :count).by(1)

    expect(response).to redirect_to(collector_path("newcollector"))
    expect(cookies[:session_id]).to be_present
  end

  it "re-renders the form when details are invalid" do
    post registration_path, params: { user: { username: "", email_address: "bad", password: "short", password_confirmation: "short" } }
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "never lets a visitor make themselves an admin" do
    post registration_path, params: { user: { username: "sneaky", email_address: "s@example.com", password: "password123", password_confirmation: "password123", admin: "1" } }
    expect(User.find_by(username: "sneaky")).not_to be_admin
  end
end
