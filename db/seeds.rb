# Creates the demo collector and a few sample titles. Safe to run more than once.
# Set DEMO_PASSWORD to choose the demo account's password.

demo = User.find_or_create_by!(username: Rails.configuration.x.demo_collector) do |user|
  user.email_address = ENV.fetch("DEMO_EMAIL", "demo@example.com")
  user.password = ENV.fetch("DEMO_PASSWORD") { SecureRandom.base58(16) }
  user.admin = true

  puts "Created the admin account #{user.username} (#{user.email_address})."
  puts "Sign in with the password #{user.password}" unless ENV["DEMO_PASSWORD"]
end

[
  { name: "Ultima VII: The Black Gate", publisher: "Origin Systems", developer: "Origin Systems", release_year: 1992, genre: "RPG", platform: "MS-DOS" },
  { name: "Wing Commander", publisher: "Origin Systems", developer: "Origin Systems", release_year: 1990, genre: "Space combat", platform: "MS-DOS" },
  { name: "SimCity 2000", publisher: "Maxis", developer: "Maxis", release_year: 1993, genre: "Simulation", platform: "MS-DOS" },
  { name: "Day of the Tentacle", publisher: "LucasArts", developer: "LucasArts", release_year: 1993, genre: "Adventure", platform: "MS-DOS" }
].each do |attributes|
  title = Title.find_or_create_by!(name: attributes[:name]) { |t| t.assign_attributes(attributes) }
  demo.collection_items.find_or_create_by!(title: title)
end
