FactoryBot.define do
  factory :email_log do
    filename { "test_email_#{Faker::Number.number(digits: 4)}.eml" }
    sender { Faker::Internet.email }
    status { :success }
    extracted_data { { name: Faker::Name.name, email: Faker::Internet.email } }
    processed_at { Time.current }

    trait :pending do
      status { :pending }
      extracted_data { nil }
      processed_at { nil }
    end

    trait :failed do
      status { :failed }
      error_message { "Processing failed: #{Faker::Lorem.sentence}" }
    end

    trait :with_file do
      after(:build) do |email_log|
        email_log.eml_file.attach(
          io: StringIO.new("From: test@example.com\nSubject: Test\n\nBody"),
          filename: email_log.filename,
          content_type: 'message/rfc822'
        )
      end
    end
  end
end
