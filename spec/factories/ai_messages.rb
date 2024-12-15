FactoryBot.define do
  factory :ai_message do
    ai_chat { nil }
    prompt { "MyText" }
    answer { "MyText" }
  end
end
