require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'index'" do

    describe "for non-signed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end

    describe "for non-admin users" do
      it "should deny access" do
        @user = test_sign_in(Factory(:user))
        get :index
        response.should redirect_to(root_path)
#flash[:notice].should =~ /sign in/i
        User.destroy(@user)
      end
    end

    describe "for admin users" do

      before(:each) do
        @user = Factory(:user)
        @user.toggle!(:admin) #Make this user an admin
        test_sign_in(@user)
        second = Factory(:user, :name => "Bob", :email => "another@example.com")
        third  = Factory(:user, :name => "Ben", :email => "athird@example.com")
        @users = [@user, second, third]
        30.times do
          @users << Factory(:user, :name => Factory.next(:name),
                                   :email => Factory.next(:email))
        end
      end
      after(:each) do
        User.destroy(@users)
      end

      it "should be successful" do
        get :index
        response.should be_success
      end

      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end

      it "should have an element for each user" do
        get :index
        @users[0..2].each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end

      it "should paginate users" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "2")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "Next")
      end
    end
  end

  describe "GET 'show'" do

    before(:each) do
      @user = Factory(:user)
    end
    after(:each) do
      User.destroy(@user)
    end

    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end

    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end

    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector("title", :content => @user.name)
    end

    it "should include the user's name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end

#    it "should have a profile image"

    it "should show the user's shared items" do
      i1 = Factory(:item, :user => @user)
      i2 = Factory(:item, :user => @user)
      get :show, :id => @user
      response.should have_selector("span.timestamp", :content => "ago")
      response.should have_selector("span.timestamp", :content => "ago")
    end

    it "should show the user's own non-shared items" do
      i = Factory(:item, :user => @user)
      i.update_attribute(:shared,false)
      test_sign_in(@user)
      get :show, :id => @user
      response.should have_selector("span.timestamp", :content => "ago")
    end

    it "should not show the user's non-shared items to other users" do
      i = Factory(:item, :user => @user)
      i.update_attribute(:shared,false)
      get :show, :id => @user
      response.should_not have_selector("span.timestamp", :content => "ago")
    end

  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end

    it "should have the right title" do
      get 'new'
      response.should have_selector("title", :content => "Sign up")
    end
  end

  describe "POST 'create'" do

    describe "failure" do

      before(:each) do
        @attr = { :name => "", :email => "", :password => "",
                  :password_confirmation => ""}
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Sign up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end
    end

    describe "success" do

      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com",
                  :password => "foobar", :password_confirmation => "foobar" }
      end
      after(:each) do
        User.destroy(assigns(:user))
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end

      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /welcome to box/i
      end

      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
    end
  end

  describe "GET 'edit'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    after(:each) do
      User.destroy(@user)
    end

    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Edit user")
    end

#    it "should have a link to change the Gravatar" do
  end

  describe "PUT 'update'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    after(:each) do
      User.destroy(@user)
    end

    describe "failure" do

      before(:each) do
        @attr = { :email => "", :name => "", :password => "",
                  :password_confirmation => "" }
      end

      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Edit user")
      end
    end

    describe "success" do

      before(:each) do
        @attr = { :name => "New Name", :email => "user@example.org",
                  :password => "barbaz", :password_confirmation => "barbaz" }
      end

      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should  == @attr[:name]
        @user.email.should == @attr[:email]
      end

      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end

  describe "authentication of edit/update pages" do

    before(:each) do
      @user = Factory(:user)
    end
    after(:each) do
      User.destroy(@user)
    end

    describe "for non-signed-in users" do

      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in users" do

      before(:each) do
        @wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in(@wrong_user)
      end
      after(:each) do
        User.destroy(@wrong_user)
      end

      it "should require matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it "should require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = Factory(:user)
    end
    after(:each) do
      User.destroy(@user)
    end

    describe "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    describe "as a non-admin user" do

      before(:each) do
        test_sign_in(@user)
      end

      describe "destroying others" do

        before(:each) do
          @other_user = Factory(:user, :email => "otheruser@example.com")
        end
        after(:each) do
          User.destroy(@other_user)
        end

        it "should deny access" do
          delete :destroy, :id => @other_user
          response.should redirect_to(root_path)
        end

        it "should not destroy the other user" do
          lambda do
            delete :destroy, :id => @other_user
          end.should_not change(User, :count)
        end
      end

      describe "destroying self" do

        after(:each) do
          @user = Factory(:user)
        end

        it "should destroy self" do
          lambda do
            delete :destroy, :id => @user
          end.should change(User, :count).by(-1)
        end

        it "should redirect to the root page" do
          delete :destroy, :id => @user
          response.should redirect_to(root_path)
        end
      end
    end

    describe "as an admin user" do

      before(:each) do
        @admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(@admin)
      end
      after(:each) do
        User.destroy(@admin)
        @user = Factory(:user)
      end

      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
    end
  end
end
