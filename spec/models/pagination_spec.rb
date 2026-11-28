require "rails_helper"

RSpec.describe Pagination do
  before { create_list(:title, 5) }

  it "splits records into pages" do
    pagination = Pagination.new(Title.alphabetical, page: 2, per_page: 2)
    expect(pagination.records.size).to eq(2)
    expect(pagination.total_count).to eq(5)
    expect(pagination.total_pages).to eq(3)
    expect(pagination.previous_number).to eq(1)
    expect(pagination.next_number).to eq(3)
  end

  it "knows the first and last pages" do
    expect(Pagination.new(Title.all, page: 1, per_page: 2)).to be_first
    expect(Pagination.new(Title.all, page: 3, per_page: 2)).to be_last
    expect(Pagination.new(Title.all, page: 3, per_page: 2).next_number).to be_nil
  end

  it "treats missing or invalid page numbers as the first page" do
    expect(Pagination.new(Title.all, page: nil).number).to eq(1)
    expect(Pagination.new(Title.all, page: "-4").number).to eq(1)
  end

  it "always has at least one page" do
    expect(Pagination.new(Title.none).total_pages).to eq(1)
  end
end
