require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "signup" do

    before { visit signup_path }

    let(:submit) { "Create" }

    describe "with invalid information" do

      it "should not make a new user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "error messages"
    end

    describe "with valid information" do

      before do
        fill_in "Name",         :with => "Example User"
        fill_in "Email",        :with => "user@example.com"
        fill_in "Password",     :with => "foobar"
        fill_in "Confirmation", :with => "foobar"
      end

      after do
      #The test will create a directory, we need to remove it.
      FileUtils.rm_rf Dir.glob("#{Rails.root}/users/user@example.com")
      end

      it "should make a new user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user"
    end
  end

  describe "sign in" do

    before { visit signin_path }

    let(:submit) { "Sign in" }

    describe "with invalid information" do
      it "should not sign a user in" do
        click_button submit
        should have_selector("div.flash.error", :text => "Invalid")
        #should not be signed in
        should have_selector("h1", :text => "Sign in")
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }

      before do
        fill_in 'Email',    :with => user.email
        fill_in 'Password', :with => user.password
        click_button submit
      end

      after { User.destroy(user) }

      #should be at the home page
      it { should have_selector('title', text: 'Home') }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
          it { should have_link('Sign in') }
          #should be at the home page (make this the signin page)
#          it {should have_selector("p", :text => "Welcome to") }
      end
    end
  end
end
