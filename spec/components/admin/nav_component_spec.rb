require "rails_helper"

RSpec.describe Admin::NavComponent, type: :component do
  it "links to each admin section and marks the current one" do
    with_request_url "/admin/users/michael/edit" do
      render_inline(described_class.new)
    end
    expect(page).to have_link("Dashboard", href: "/admin")
    expect(page).to have_link("Titles", href: "/admin/titles")
    expect(page).to have_css("a[aria-current='page']", text: "Users")
    expect(page).not_to have_css("a[aria-current='page']", text: "Dashboard")
  end
end
