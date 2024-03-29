require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'index'" do

    describe "as a non-signed-in user" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end

    describe "as a non-admin user" do
      it "should deny access" do
        @user = FactoryGirl.create(:user)
        test_sign_in @user
        get :index
        response.should redirect_to(root_path)
#flash[:notice].should =~ /sign in/i
        User.destroy(@user)
      end
    end

    describe "as an admin user" do

      before(:each) do
        @admin = test_sign_in(FactoryGirl.create(:admin))
        controller.should be_signed_in
        second = FactoryGirl.create(:user, :name => "Bob", :email => "another@example.com")
        third  = FactoryGirl.create(:user, :name => "Ben", :email => "athird@example.com")
        @users = [@admin, second, third]
        30.times do
          @users << FactoryGirl.create(:user)
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
        response.body.should have_selector("title", :text => "All users")
      end

      it "should have an element for each user" do
        get :index
        @users[0..2].each do |user|
          response.body.should have_selector("li", :text => user.name)
        end
      end

      it "should paginate users" do
        get :index
        response.body.should have_selector("div.pagination")
        response.body.should have_selector("span.disabled", :text => "Previous")
        response.body.should have_selector("a", :href => "/users?page=2",
                                           :text => "2")
        response.body.should have_selector("a", :href => "/users?page=2",
                                           :text => "Next")
      end
    end
  end

  describe "GET 'show'" do

    before(:each) do
      @user = FactoryGirl.create(:user)
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
      response.body.should have_selector("title", :text => @user.name)
    end

    it "should include the user's name" do
      get :show, :id => @user
      response.body.should have_selector("h1", :text => @user.name)
    end

#    it "should have a profile image"

    it "should show the user's shared items" do
      i1 = FactoryGirl.create(:item, :user => @user)
      i2 = FactoryGirl.create(:item, :user => @user)
      get :show, :id => @user
      response.body.should have_selector("span.timestamp", :text => "ago")
      response.body.should have_selector("span.timestamp", :text => "ago")
    end

    it "should show the user's own non-shared items" do
      i = FactoryGirl.create(:item, :user => @user)
      i.update_attribute(:shared,false)
      test_sign_in(@user)
      get :show, :id => @user
      response.body.should have_selector("span.timestamp", :text => "ago")
    end

    it "should not show the user's non-shared items to other users" do
      i = FactoryGirl.create(:item, :user => @user)
      i.update_attribute(:shared,false)
      get :show, :id => @user
      response.body.should_not have_selector("span.timestamp", :text => "ago")
    end
  end

  describe "GET 'new'" do

    describe "as a non-signed-in first user" do
      it "should be successful" do
        get 'new'
        response.should be_success
      end
    end

    describe "as a non-signed-in non-first user" do

      it "should deny access" do
        @first = FactoryGirl.create(:user)
        get 'new'
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
        User.destroy(@first)
      end
    end

    describe "as a non-admin user" do

      it "should deny access" do
        @user = test_sign_in(FactoryGirl.create(:user))
        get 'new'
        response.should redirect_to(root_path)
        User.destroy(@user)
      end
    end

    describe "as an admin user" do

      before(:each) do
        @admin = test_sign_in(FactoryGirl.create(:user, :admin => true))
      end
      after(:each) do
        User.destroy(@admin)
      end

      it "should be successful" do
        get 'new'
        response.should be_success
      end

      it "should have the right title" do
        get 'new'
        response.body.should have_selector("title", :text => "New User")
      end
    end
  end

  describe "POST 'create'" do

    describe "as non-signed-in first user" do

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
          response.body.should have_selector("title", :text => "New User")
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

        it "should make the user an admin" do
          post :create, :user => @attr
          assigns(:user).should be_admin
        end

        it "should redirect to the user show page" do
          post :create, :user => @attr
          response.should redirect_to(user_path(assigns(:user)))
        end

        it "should have a success message" do
          post :create, :user => @attr
          flash[:success].should =~ /created/i
        end

        it "should sign in the new user" do
          post :create, :user => @attr
          controller.should be_signed_in
        end
      end
    end

    describe "as a non-signed-in non-first user" do

      it "should deny access" do
        @first = FactoryGirl.create(:user)
        post :create, :user => {}
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
        User.destroy(@first)
      end
    end

    describe "as a non-admin user" do

      it "should deny access" do
        @user = test_sign_in(FactoryGirl.create(:user))
        post :create, :user => {}
        response.should redirect_to(root_path)
        User.destroy(@user)
      end
    end

    describe "as an admin user" do

      before(:each) do
        @admin = test_sign_in(FactoryGirl.create(:user, :admin => true))
      end
      after(:each) do
        User.destroy(@admin)
      end

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
          response.body.should have_selector("title", :text => "New User")
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

        it "should have a success message" do
          post :create, :user => @attr
          flash[:success].should =~ /created/i
        end

        it "should not sign in the new user" do
          post :create, :user => @attr
          controller.current_user.should_not == assigns(:user)
        end
      end
    end
  end

  describe "GET 'edit'" do

    before(:each) do
      @user = FactoryGirl.create(:user)
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
      response.body.should have_selector("title", :text => "Edit user")
    end

#    it "should have a link to change the Gravatar" do
  end

  describe "PUT 'update'" do

    before(:each) do
      @user = FactoryGirl.create(:user)
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
        response.body.should have_selector("title", :text => "Edit user")
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
      @user = FactoryGirl.create(:user)
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
        @wrong_user = FactoryGirl.create(:user, :email => "user@example.net")
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
      @user = FactoryGirl.create(:user)
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
          @other_user = FactoryGirl.create(:user, :email => "otheruser@example.com")
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
          @user = FactoryGirl.create(:user)
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
        @admin = FactoryGirl.create(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(@admin)
      end
      after(:each) do
        User.destroy(@admin)
        @user = FactoryGirl.create(:user)
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
