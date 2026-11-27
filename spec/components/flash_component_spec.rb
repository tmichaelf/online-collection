require "rails_helper"

RSpec.describe FlashComponent, type: :component do
  it "renders notices and alerts" do
    render_inline(described_class.new(flash: { notice: "Saved", alert: "Oops" }))
    expect(page).to have_css(".flash--notice", text: "Saved")
    expect(page).to have_css(".flash--alert", text: "Oops")
  end

  it "renders nothing when the flash is empty" do
    render_inline(described_class.new(flash: {}))
    expect(page).not_to have_css(".flash")
  end
end
