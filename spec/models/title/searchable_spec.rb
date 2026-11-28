require "rails_helper"

RSpec.describe Title::Searchable, type: :model do
  let!(:ultima) { create(:title, name: "Ultima VII: The Black Gate", publisher: "Origin Systems", developer: "Origin Systems", genre: "RPG", platform: "MS-DOS", release_year: 1992, description: "Britannia needs an Avatar.") }
  let!(:wing) { create(:title, name: "Wing Commander", publisher: "Origin Systems", developer: "Origin Systems", genre: "Space combat", platform: "MS-DOS", release_year: 1990) }
  let!(:simcity) { create(:title, name: "SimCity 2000", publisher: "Maxis", developer: "Maxis", genre: "Simulation", platform: "Windows", release_year: 1993) }
  let!(:loom) { create(:title, name: "Loom", publisher: "Lucasfilm Games", developer: "Lucasfilm Games", genre: "Adventure", platform: "Amiga", release_year: 1990, created_at: 1.day.from_now) }

  describe ".matching" do
    it "finds titles by the start of each word" do
      expect(Title.matching("ultim vii")).to eq([ ultima ])
    end

    it "searches publisher, developer, genre, platform and description" do
      expect(Title.matching("maxis")).to eq([ simcity ])
      expect(Title.matching("space")).to eq([ wing ])
      expect(Title.matching("amiga")).to eq([ loom ])
      expect(Title.matching("britannia")).to eq([ ultima ])
    end

    it "ranks name matches above other matches" do
      create(:title, name: "Origin Story", publisher: "Someone Else")
      expect(Title.matching("origin").first.name).to eq("Origin Story")
    end

    it "ignores punctuation and returns everything for a blank query" do
      expect(Title.matching("ultima: vii!")).to eq([ ultima ])
      expect(Title.matching("  ").count).to eq(4)
    end
  end

  describe ".search" do
    it "combines a query with filters" do
      expect(Title.search(query: "origin", genre: "RPG")).to eq([ ultima ])
      expect(Title.search(publisher: "Origin Systems", decade: "1990")).to eq([ ultima, wing ])
      expect(Title.search(platform: "Windows")).to eq([ simcity ])
    end

    it "ignores a malformed decade" do
      expect(Title.search(decade: "nineties").count).to eq(4)
    end

    it "sorts by name by default and by the chosen order" do
      expect(Title.search.map(&:name)).to eq([ "Loom", "SimCity 2000", "Ultima VII: The Black Gate", "Wing Commander" ])
      expect(Title.search(sort: "newest").first).to eq(simcity)
      expect(Title.search(sort: "oldest").map(&:release_year).first).to eq(1990)
      expect(Title.search(sort: "recent").first).to eq(loom)
    end
  end

  describe ".filter_options" do
    it "lists the publishers, genres, platforms and decades in the archive" do
      options = Title.filter_options
      expect(options[:publishers]).to eq([ "Lucasfilm Games", "Maxis", "Origin Systems" ])
      expect(options[:platforms]).to eq([ "Amiga", "MS-DOS", "Windows" ])
      expect(options[:decades]).to eq([ 1990 ])
    end
  end
end
