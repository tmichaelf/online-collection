require "rails_helper"

RSpec.describe TitleCardComponent, type: :component do
  let(:title) { build_stubbed(:title, name: "SimCity 2000", publisher: "Maxis", release_year: 1993) }

  it "shows the name, publisher and year" do
    render_inline(described_class.new(title: title))
    expect(page).to have_link("SimCity 2000")
    expect(page).to have_text("Maxis · 1993")
  end

  it "shows a zero-padded archive record number" do
    title.id = 42
    render_inline(described_class.new(title: title))
    expect(page).to have_css(".title-card__record", text: "No. 0042")
  end

  it "shows the condition badge when given one" do
    render_inline(described_class.new(title: title, condition: "sealed"))
    expect(page).to have_css(".badge--sealed", text: "Sealed")
  end
end
