FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    password 'f4k3p455w0rd'
    sequence(:username) { |n| "president#{n}" }
  end
end
