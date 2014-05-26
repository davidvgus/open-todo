# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :item do
    list
    description { Faker::Lorem.sentence(2) }
    completed false
  end
end
