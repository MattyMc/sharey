class PagesController < ApplicationController
  def home
  end

  def my_friends
    # This is just for debugging
    # matt = User.last
    redirect_to(root_url, alert:"You need to login first!") if current_user.nil? 
    @friends = Friend.where user:current_user


    # Keep this:
    @new_friend = Friend.new # This will ultimately be delivered to Friends controller
  end

  def saved_items
  end

  def about
  end
end
