class PagesController < ApplicationController
  def home
  end

  def my_friends
    # This is just for debugging
    matt = User.last
    @friends = Friend.where user:matt

    # Keep this:
    @new_friend = Friend.new # This will ultimately be delivered to Friends controller
  end

  def saved_items
  end

  def about
  end
end
