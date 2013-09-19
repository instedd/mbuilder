require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.define do
  name { Faker::Name.name }
  email { Faker::Internet.email }
  password { Faker::Name.name }
  username { Faker::Internet.user_name }
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
end

Trigger.blueprint do
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
