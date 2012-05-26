#By using the symbol ':user', we get Factory Girl to simulate the User model.
FactoryGirl.define do
  factory :user do
    sequence(:name)        { |n| "Person #{n}" }
    sequence(:email)       { |n| "person#{n}@example.com" }
    password               "foobar"
    password_confirmation  "foobar"

    factory :admin do
      admin true
    end
  end

  factory :item do
    shared true
    association :user
    file  Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/TestFile.mp3'),'mp3')
  end
end
