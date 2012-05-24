namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    admin = User.create!(:name => "Example User",
                         :email => "example@example.org",
                         :password => "foobar",
                         :password_confirmation => "foobar")
    admin.toggle!(:admin)
    99.times do |n|
      name = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password = "password"
      User.create!(:name => name,
                   :email => email,
                   :password => password,
                   :password_confirmation => password)
    end
    10.times do
      User.all(:limit => 3).each do |user|
        user.items.create!(:shared => true,
                           :file => Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/TestFile.mp3'),'mp3'))
      end
    end
  end
end
