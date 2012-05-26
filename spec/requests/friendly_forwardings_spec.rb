require 'spec_helper'

describe "FriendlyForwardings" do

  subject { page }

  let (:user) { FactoryGirl.create(:user) }

  before do
    visit edit_user_path(user)
    # The test automatically follows the redirect to the signin page.
    fill_in 'Email',    :with => user.email
    fill_in 'Password', :with => user.password
    click_button "Sign in"
    # The test follows the redirect again, this time to users/edit.
  end

  after { User.destroy(user) }

  describe "should forward to the requested page after signin" do
    it {should have_selector('h1', :text => 'Edit') }
  end
end
