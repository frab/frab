# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Daley', city: cities.first)
PaperTrail.enabled = false

person = Person.create!(
  email: 'admin@example.org',
  first_name: 'admin',
  last_name: 'admin',
  public_name: 'admin_127'
)

admin = User.new(
  email: person.email,
  password: 'test123',
  password_confirmation: 'test123'
)
admin.person = person
admin.role = 'admin'
admin.confirmed_at = Time.now
admin.save!
