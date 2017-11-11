FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    password "password"
    sequence(:username) { |n| "person#{n}" }

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
