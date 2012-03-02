# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  share_path         :string(255)
#

require 'spec_helper'

describe User do

  before(:each) do
    @attr = {
      :name => "Example User", 
      :email => "user@example.com",
      :password => "foobar",
      :password_confirmation => "foobar"
    }
  end

  #Sanity check
  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  #Name
  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end

  it "should reject names that are too long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end

  #Email
  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    # Put a user with given email address into the database.
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  #Password
  describe "password validations" do

    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end

    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
        should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 51
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end
  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do

      it "should be true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end

      it "should be false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end
    end
    describe "authenticate method" do

      it "should return nil on email/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
        wrong_password_user.should be_nil
      end

      it "should return nil for an email address with no user" do
        nonexistent_user = User.authenticate("bar@foo.com",@attr[:password])
        nonexistent_user.should be_nil
      end

      it "should return the user on email/password match" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end
  end

  describe "item associations" do
    before(:each) do
      @user = User.create(@attr)
      @i1 = Factory(:item, :user => @user, :created_at => 1.day.ago)
      @i2 = Factory(:item, :user => @user, :created_at => 1.hour.ago)
    end

    it "should have an items attribute" do
      @user.should respond_to(:items)
    end

#    it "should have the items in the right order"

    it "should destroy associated items" do
      @user.destroy
      [@i1, @i2].each do |item|
        Item.find_by_id(item.id).should be_nil
      end
    end
  end

  #Share Directory
  describe "share directory" do

    describe "share_path attribute" do
      before(:each) do
        @user = User.create(@attr)
      end
      after(:each) do
        User.destroy(@user)
      end

      it "should have a share_path attribute" do
        @user.should respond_to(:share_path)
      end

      it "should set the share_path attribute" do
        @user.share_path.should_not be_blank
      end
    end
    it "should create the share directory for the user upon creation" do
      File.directory?(Rails.root.join(@attr[:name])).should be_false
      @user = User.create(@attr)
      File.directory?(Rails.root.join(@attr[:name])).should be_true
      User.destroy(@user)
    end

    it "should destroy the share directory for the user upon destruction" do
      @user = User.create(@attr)
      File.directory?(Rails.root.join(@user[:name])).should be_true
      User.destroy(@user)
      File.directory?(Rails.root.join(@user[:name])).should be_false
    end
  end
end
