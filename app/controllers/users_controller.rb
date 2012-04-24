class UsersController < ApplicationController
  before_filter :authenticate, :only => [:index, :edit, :update, :destroy]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user, :only => :index
  before_filter :create_new_user, :only => [:new,:create]
  before_filter :user_destroy, :only => :destroy

  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
  end

  def show
    @user = User.find(params[:id])
    @items = @user.items #.paginate(:page => params[:page])
    @title = @user.name
  end

  def new
    @user = User.new
    @title = "New User"
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      @user.toggle!(:admin) if User.first == @user #Make the first user an admin
      sign_in @user unless signed_in?
      flash[:success] = "A new account was successfuly created."
      redirect_to @user
    else
      @title = "New User"
      render 'new'
    end
  end

  def edit
    @title = "Edit user"
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    if current_user.admin?
      flash[:success] = "User destroyed."
      redirect_to users_path and return
    else
      flash[:success] = "Your account has been successfuly deleted."
      redirect_to root_path
    end
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

    def create_new_user
      unless signed_in?
        if User.all.empty? #First user can be create itself.
          return
        else
          deny_access and return
        end
      end #All other users are created by admin.
      redirect_to(root_path) unless current_user.admin?
    end

    def user_destroy
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user.admin? or current_user?(@user)
    end
end
