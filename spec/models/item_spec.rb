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
    @attr = {}
  end

  it "should create a new instance given valid attributes" do
    @user.items.create!(@attr)
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

  describe "validations" do

    it "should require a user id" do
      Item.new(@attr).should_not be_valid
    end

    it "should require a private path" #do
#      @user.items.build(:private_path => nil).should_not be_valid
#    end
  end
end
