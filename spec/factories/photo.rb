FactoryBot.define do
  factory :photo do
    image { Faker::Avatar.image }
    caption "Lake Bondhus"
  end
end
