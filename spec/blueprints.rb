require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.define do
  name { Faker::Name.name }
  email { Faker::Internet.email }
  password { Faker::Name.name }
  username { Faker::Internet.user_name }
  address { Faker::PhoneNumber.phone_number }
  url { Faker::Internet.url }
end

User.blueprint do
  email
  password
  password_confirmation { password }
  confirmed_at { Time.now - 1.day }
end

Application.blueprint do
  user
  name
  time_zone "Athens"
end

MessageTrigger.blueprint do
  application
  name
end

ExternalTrigger.blueprint do
  application
  name
end

PeriodicTask.blueprint do
  application
  name
end

ValidationTrigger.blueprint do
  application
end

Channel.blueprint do
  application
  name
end

Contact.blueprint do
  application
  address
end

ExternalService.blueprint do
  application
  url
end
