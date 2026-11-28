require "rails_helper"

RSpec.describe PaginationComponent, type: :component do
  before { create_list(:title, 3) }

  it "links to neighbouring pages and keeps the filters" do
    pagination = Pagination.new(Title.all, page: 2, per_page: 1)
    with_request_url "/titles" do
      render_inline(described_class.new(pagination: pagination, params: { "q" => "origin" }))
    end
    expect(page).to have_link("Previous", href: "/titles?page=1&q=origin")
    expect(page).to have_link("Next", href: "/titles?page=3&q=origin")
    expect(page).to have_text("Page 2 of 3")
  end

  it "renders nothing when everything fits on one page" do
    render_inline(described_class.new(pagination: Pagination.new(Title.all), params: {}))
    expect(page).not_to have_css(".pagination")
  end
end
