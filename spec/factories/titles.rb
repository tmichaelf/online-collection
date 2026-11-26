FactoryBot.define do
  factory :title do
    sequence(:name) { |n| "Big Box Game #{n}" }
    publisher { "Origin Systems" }
    developer { "Origin Systems" }
    release_year { 1992 }
    genre { "RPG" }
    platform { "MS-DOS" }
  end
end
