#By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.name                   "Jonathan Paez"
  user.email                  "jpaez@example.com"
  user.password               "foobar"
  user.password_confirmation  "foobar"
end

Factory.sequence :name do |n|
  "Person #{n}"
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

Factory.define :item do |item|
  item.shared true
  item.association :user
  item.file  Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/TestFile.mp3'),'mp3')
end
