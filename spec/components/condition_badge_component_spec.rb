require "rails_helper"

RSpec.describe ConditionBadgeComponent, type: :component do
  it "labels each condition" do
    render_inline(described_class.new(condition: "box_only"))
    expect(page).to have_css(".badge.badge--box-only", text: "Box only")
  end
end
