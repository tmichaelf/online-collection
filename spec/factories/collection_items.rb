FactoryBot.define do
  factory :collection_item do
    user
    title
    condition { "complete" }
  end
end
