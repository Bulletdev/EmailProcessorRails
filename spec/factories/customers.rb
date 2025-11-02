FactoryBot.define do
  factory :customer do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    product_code { "PROD-#{Faker::Number.number(digits: 3)}" }
    subject { Faker::Lorem.sentence }
  end

  factory :customer_with_email_only, parent: :customer do
    phone { nil }
  end

  factory :customer_with_phone_only, parent: :customer do
    email { nil }
  end
end
