class PagesController < ApplicationController
  def home
  end

  def my_friends
    # This is just for debugging
    # matt = User.last
    redirect_to(root_url, alert:"You need to login first!") if current_user.nil? 
    @friends = Friend.where(user:current_user).order(:confirmed, :created_at)

    # Display a nice message to add tags if a user has undefined friends
    if @friends.pluck(:confirmed).include?(false)
      flash[:notice] = "People have added you as a friend. Set their tags by clicking on 'My Friends' and start Sharey'ing things with them!"
    end

  end

  def saved_items
  end

  def about
  end
end
