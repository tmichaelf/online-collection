require "rails_helper"

RSpec.describe "Managing titles", type: :system do
  it "lets an admin add a title with box photos that visitors can see" do
    sign_in_as create(:user, :admin)

    click_on "Admin"
    within(".admin-nav") { click_on "Titles" }
    click_on "New title"
    fill_in "Name", with: "Day of the Tentacle"
    fill_in "Publisher", with: "LucasArts"
    attach_file "Front", file_fixture("front.png")
    attach_file "Left side", file_fixture("side.png")
    click_on "Create Title"

    expect(page).to have_text("Title created.")
    expect(page).to have_link("Remove photo", count: 2)

    click_on "Sign out"
    visit titles_path
    click_on "Day of the Tentacle"
    expect(page).to have_css("figcaption", text: "Front")
    expect(page).to have_css("figcaption", text: "Left side")
  end
end
