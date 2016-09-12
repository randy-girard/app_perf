# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
user = User.create(:email => "user@example.com", :password => "password")
application = user.applications.create(:name => "App Perf")
application.update_column(:license_key, "19509de2-d07d-470f-a8f5-aab940569d84")
