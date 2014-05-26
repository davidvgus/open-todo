# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :list do
    user
    name { Faker::Lorem.word }
    permissions "private"
  end
end
