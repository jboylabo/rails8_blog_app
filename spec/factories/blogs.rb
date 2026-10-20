FactoryBot.define do
  factory :blog do
    association :user
    sequence(:title) { |n| "Test title #{n}" }
    post { "Test post body" }
  end
end
