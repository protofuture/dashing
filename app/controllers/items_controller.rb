class ItemsController < ApplicationController
  before_filter :authenticate, :only => [:create, :edit, :update, :destroy]
  before_filter :authorized_user, :only => [:edit, :update, :destroy]
  before_filter :shared_item, :only => [:show, :get_file]

  def create
    @item = current_user.items.build(params[:item])
    if @item.save
      flash[:success] = "Item created!"
      redirect_to root_path
    else
      render 'pages/home'
    end
  end

  def destroy
    @item.destroy
    flash[:success] = "Item deleted."
    redirect_back_or root_path
  end

  def get_file
    @item = Item.find(params[:id])
    send_file @item.full_path
  end

  def show
    @item = Item.find(params[:id])
    @title = @item.private_path
  end

  def edit
    @item = Item.find(params[:id])
    @title = "Edit item"
  end

  def update
    @item = Item.find(params[:id])
    @title = "Edit item"
    if @item.update_attributes(params[:item])
      flash[:success] = "Item updated."
      redirect_to @item
    else
      @title = "Edit item"
      render 'edit'
    end
  end

  private

    def authorized_user
      @item = Item.find(params[:id])
      redirect_to root_path unless current_user?(@item.user)
    end

    def shared_item
      @item = Item.find(params[:id])
      if signed_in?
        unless @item.shared? or current_user?(@item.user)
          redirect_to root_path 
        end
      else
        redirect_to signin_path
      end
    end
end
