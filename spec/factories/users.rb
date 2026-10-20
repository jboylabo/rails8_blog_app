FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "test-password-12" }
    password_confirmation { password }
  end
end
