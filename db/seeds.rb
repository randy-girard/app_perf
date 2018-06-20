# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create(
  :name => "User Example",
  :email => "user@example.com",
  :password => "password",
  :license_key => "30b5805c-25d8-4fcd-875e-4fd9be32993e"
)
Application.create(
  :name => "App Perf",
  :license_key => ENV["APP_PERF_LICENSE_KEY"]
)
