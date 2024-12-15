FactoryBot.define do
  factory :ai_chat do
    user { nil }
    title { "Hi" }
    ai_model_name { "llama3.2" }
  end
end
