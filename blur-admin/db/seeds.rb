# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

User.create({:username => 'admin',
            :name => 'Delete Me',
            :password => 'password',
            :password_confirmation =>
            'password',
            :email => 'admin@blurtools.io',
            :roles_mask => 31}, :without_protection => true)