FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n+1}@rspec.com" }
    password { 'Blabla12345!' }
    password_confirmation { 'Blabla12345!' }
  end
end
