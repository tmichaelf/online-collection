require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

  it { is_expected.to have_many(:collection_items).dependent(:destroy) }
  it { is_expected.to have_many(:titles).through(:collection_items) }
  it { is_expected.to validate_presence_of(:username) }
  it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
  it { is_expected.to validate_length_of(:password).is_at_least(8) }

  it "normalizes username and email address" do
    user = build(:user, username: " Michael ", email_address: " Michael@Example.COM ")
    expect(user.username).to eq("michael")
    expect(user.email_address).to eq("michael@example.com")
  end

  it "rejects usernames with spaces or symbols" do
    expect(build(:user, username: "big box!")).not_to be_valid
  end

  it "uses the username in URLs" do
    expect(build(:user, username: "michael").to_param).to eq("michael")
  end

  describe ".demo" do
    it "finds the configured demo collector" do
      demo = create(:user, username: Rails.configuration.x.demo_collector)
      expect(User.demo).to eq(demo)
    end
  end
end
