require 'spec_helper'

describe PagesController do
  render_views

  before(:each) do
    @base_title = "Box"
  end

  describe "GET 'home'" do
    it "should be successful" do
      get 'home'
      response.should be_success
    end

    it "should have the right title" do
      get 'home'
      response.body.should have_selector("title",
			:content => @base_title + " | Home")
    end
  end

  describe "GET 'about'" do
    it "should be successful" do
      get 'about'
      response.should be_success
    end

    it "should have the right title" do
      get 'about'
      response.body.should have_selector("title",
			:content =>  @base_title + " | About")
    end
  end
end
