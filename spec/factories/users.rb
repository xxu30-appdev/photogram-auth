FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    password 'f4k3p455w0rd'
    sequence(:username) { |n| "president#{n}" }
    factory :user_with_photos do
      transient do
        photos_count 1
      end

      after(:create) do |user, evaluator|
        create_list(:photo, evaluator.photos_count, user: user)
      end
    end
  end
end
