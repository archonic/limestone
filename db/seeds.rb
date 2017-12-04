# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user = CreateAdminService.call
puts 'CREATED ADMIN USER: ' << user.email
test_users = User.create([{email: 'test@example.com', first_name: 'Firsty', last_name: 'McLast', password: 'password'}])
CreatePlanService.call
puts 'CREATED PLANS'
