class ItemsController < ApplicationController
  before_filter :authenticate, :only => [:create, :destroy]
  before_filter :authorized_user, :only => [:destroy]

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
    redirect_back_or root_path
  end

  private

    def authorized_user
      @item = Item.find(params[:id])
      redirect_to root_path unless current_user?(@item.user)
    end
end
