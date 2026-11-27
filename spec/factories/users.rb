FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "collector#{n}" }
    sequence(:email_address) { |n| "collector#{n}@example.com" }
    password { "password123" }

    trait :admin do
      admin { true }
    end
  end
end
