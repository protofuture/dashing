class PagesController < ApplicationController
  def home
    @title = "Home"
    if signed_in?
      @item = Item.new
      @shared_items = current_user.items.where(:shared => true)
      @private_items = current_user.items.where(:shared => false)
    end
  end

  def contact
    @title = "Contact"
  end

  def about
    @title = "About"
  end

  def help
    @title = "Help"
  end
end
