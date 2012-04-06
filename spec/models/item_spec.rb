# == Schema Information
#
# Table name: items
#
#  id           :integer         not null, primary key
#  private_path :string(255)
#  user_id      :integer
#  shared       :boolean
#  created_at   :datetime
#  updated_at   :datetime
#

require 'spec_helper'

describe Item do

  before(:each) do
    @user = Factory(:user)
    @attr = {
      :shared => true,
      :file => Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/TestFile.mp3'),'mp3'),
      :private_path => "TestFile.mp3"
    }
  end
  after(:each) do
    User.destroy(@user)
  end

  #Sanity check
  it "should create a new instance given valid attributes" do
    @user.items.create!(@attr)
  end

  describe "validations" do

    #User ID
    it "should require a user id" do
      Item.new(@attr).should_not be_valid
    end

    #Shared setting
    it "should require a shared setting" #do
#      no_shared_item = @user.items.new(@attr.merge(:shared => nil))
#      no_shared_item.should_not be_valid
#    end

    #Filename
    it "should require a file upload" do
      no_filename_item = @user.items.new(@attr.merge(:file =>nil))
      no_filename_item.should_not be_valid
    end
  end

  describe "user associations" do

    before(:each) do
      @item = @user.items.create(@attr)
    end

    it "should have a user attribute" do
      @item.should respond_to(:user)
    end

    it "should have the right associated user" do
      @item.user_id.should == @user.id
      @item.user.should == @user
    end
  end

end
