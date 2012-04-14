require 'spec_helper'

describe ItemsController do
  render_views

  describe "access control" do

    it "should deny access to 'create'" do
      post :create
      response.should redirect_to(signin_path)
    end

    it "should deny access to 'destroy'" do
      delete :destroy, :id => 1
      response.should redirect_to(signin_path)
    end
  end

  describe "GET 'show'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      @item = Factory(:item, :user => @user)
    end
    after(:each) do
      User.destroy(@user)
    end

    it "should be successful" do
      get :show, :id => @item
      response.should be_success
    end

    it "should find the right item" do
      get :show, :id => @item
      assigns(:item).should == @item
    end

    it "should have the right title" do
      get :show, :id => @item
      response.should have_selector("title", :content => @item.private_path)
    end

    it "should include the item's filename" do
      get :show, :id => @item
      response.should have_selector("h1", :content => @item.private_path)
    end
  end

  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
    end
    after(:each) do
      User.destroy(@user)
    end

    describe "failure" do

      before(:each) do
        @attr = {}
      end

      it "should not create an item" do
        lambda do
          post :create, :item => @attr
        end.should_not change(Item, :count)
      end

      it "should render the home page" do
        post :create, :item => @attr
        response.should render_template('pages/home')
      end
    end

    describe "success" do

      before(:each) do
        @attr = {
          :file => Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/TestFile.mp3'),'mp3'),
          :shared => true
        }
      end

      it "should create an item" do
        lambda do
          post :create, :item => @attr
        end.should change(Item, :count).by(1)
      end

      it "should redirect to the home page" do
        post :create, :item => @attr
        response.should redirect_to(root_path)
      end

      it "should have a flash message" do
        post :create, :item => @attr
        flash[:success].should =~ /item created/i
      end
    end
  end

  describe "GET 'edit'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      @item = Factory(:item, :user => @user)
    end
    after(:each) do
      User.destroy(@user)
    end

    it "should be successful" do
      get :edit, :id => @item
      response.should be_success
    end
    it "should have the right title" do
      get :edit, :id => @item
      response.should have_selector("title", :content => "Edit item")
    end
  end

  describe "PUT 'update'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      @item = Factory(:item, :user => @user)
    end
    after(:each) do
      User.destroy(@user)
    end

    describe "failure"
    describe "success" do
      before(:each) do
        @attr = {:shared => false}
      end

      it "should change the item's attributes" do
        put :update, :id => @item, :item => @attr
        @item.reload
        @item.shared.should == @attr[:shared]
      end

      it "should redirect to the item show page" do
        put :update, :id => @item, :item => @attr
        response.should redirect_to(item_path(@item))
      end

      it "should have a flash message" do
        put :update, :id => @item, :item => @attr
        flash[:success].should =~ /updated/
      end
    end
  end

  describe "authentication of edit/update pages" do

    before(:each) do
      @user = Factory(:user)
      @item = Factory(:item, :user => @user)
    end
    after(:each) do
      User.destroy(@user)
    end

    describe "for non-signed-in users" do

      it "should deny access to 'edit'" do
        get :edit, :id => @item
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, :id => @item, :item => {}
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in users" do

      before(:each) do
        @wrong_user = Factory(:user, :email => Factory.next(:email))
        test_sign_in(@wrong_user)
      end
      after(:each) do
        User.destroy(@wrong_user)
      end

      it "should require matching users for 'edit'" do
        get :edit, :id => @item
        response.should redirect_to(root_path)
      end

      it "should require matching users for 'update'" do
        put :update, :id => @item, :item => {}
        response.should redirect_to(root_path)
      end
    end
  end

  describe "DELETE 'destroy'" do

    describe "for an unauthorized user" do

      before(:each) do
        @user = Factory(:user)
        @wrong_user = Factory(:user, :email => Factory.next(:email))
        test_sign_in(@wrong_user)
        @item = Factory(:item, :user => @user)
      end
      after(:each) do
        User.destroy(@user)
        User.destroy(@wrong_user)
      end

      it "should deny access" do
        delete :destroy, :id => @item
        response.should redirect_to(root_path)
      end
    end

    describe "for an authorized user" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        @item = Factory(:item, :user => @user)
      end
      after(:each) do
        User.destroy(@user)
      end

      it "should destroy the item" do
        lambda do
          delete :destroy, :id => @item
        end.should change(Item, :count).by(-1)
      end
    end
  end
end
