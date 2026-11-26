require "rails_helper"

RSpec.describe "Collecting", type: :system do
  it "signs up, adds a title and shows it on the public collection page" do
    create(:title, name: "Day of the Tentacle")

    visit new_registration_path
    fill_in "Username", with: "tentaclefan"
    fill_in "Email address", with: "fan@example.com"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"
    click_on "Create account"

    click_on "Titles"
    click_on "Day of the Tentacle"
    select "Sealed", from: "Condition"
    click_on "Add to my collection"
    expect(page).to have_text("Added to your collection.")

    click_on "Sign out"
    visit collector_path("tentaclefan")
    expect(page).to have_text("Day of the Tentacle")
    expect(page).to have_text("Sealed")
  end
end
