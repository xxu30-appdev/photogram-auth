FactoryBot.define do
  factory :photo do
    sequence(:image) { |n| "https://some.url/image#{n}.png" }
    sequence(:caption) { |n| "Some caption #{n}" }
  end
end
