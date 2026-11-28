require "rails_helper"
require "rake"

RSpec.describe "users rake tasks" do
  before(:all) do
    Rails.application.load_tasks if Rake::Task.tasks.none? { |task| task.name == "users:grant_admin" }
  end

  def run(task, *args)
    Rake::Task[task].reenable
    Rake::Task[task].invoke(*args)
  end

  it "grants admin access by username or email address" do
    user = create(:user, username: "michael", email_address: "michael@example.com")
    expect { run("users:grant_admin", "michael") }.to output(/michael \(michael@example.com\) is now an admin/).to_stdout
    expect(user.reload).to be_admin

    expect { run("users:revoke_admin", "Michael@Example.com") }.to output(/is no longer an admin/).to_stdout
    expect(user.reload).not_to be_admin
  end

  it "stops when there is no such account" do
    expect { run("users:grant_admin", "nobody") }.to raise_error(SystemExit).and output(/No account/).to_stderr
  end
end
