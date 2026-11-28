require "rails_helper"

RSpec.describe TitleFiltersComponent, type: :component do
  let(:options) { { publishers: [ "Maxis" ], genres: [ "RPG" ], platforms: [ "MS-DOS" ], decades: [ 1980, 1990 ] } }

  it "renders the search box and filters with the current choices" do
    render_inline(described_class.new(filters: { "q" => "ultima", "decade" => "1990" }.with_indifferent_access, options: options))
    expect(page).to have_field("Search titles", with: "ultima")
    expect(page).to have_select("Publisher", options: [ "Any publisher", "Maxis" ])
    expect(page).to have_select("Decade", selected: "1990s")
    expect(page).to have_select("Sort by", options: [ "Best match", "Name", "Newest release", "Oldest release", "Recently added" ])
  end
end
