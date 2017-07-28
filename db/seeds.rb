# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
user = User.create(
  :name => "User Example",
  :email => "user@example.com",
  :password => "password"
)
organization = user.organizations.create(
  :name => "Organization #1",
  :license_key => ENV["APP_PERF_LICENSE_KEY"]
)
application = organization.applications.create(
  :name => "App Perf"
)
