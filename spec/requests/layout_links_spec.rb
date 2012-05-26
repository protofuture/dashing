require 'spec_helper'

describe "LayoutLinks" do

  subject { page }

  describe "should have a Home page at '/'" do
    before { visit root_path }

    it { should have_selector('title', :text => "Home") }
  end

  describe "should have an About page at '/about'" do
    before { visit about_path }
    it { should have_selector('title', :text => "About") }
  end

  describe "should have a signup page at '/signup'" do
    before { visit signup_path }
    it { should have_selector('title', :text => "New User") }
  end

  describe "when not signed in" do
    describe "should have a signin link" do
      before { visit root_path }
      it { should have_selector("a", :href => signin_path,
                                         :text => "Sign in")
      }
    end
  end

  describe "when signed in" do

    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
      visit root_path
    end

    after { User.destroy(user) }

    describe "should have a signout link" do
      it { should have_selector("a", :href => signout_path,
                                         :text => "Sign out")
      }
    end

    describe "should have a profile link" do
      it { should have_selector("a", :href => user_path(user),
                                         :text => "Profile")
      }
    end
  end
end
