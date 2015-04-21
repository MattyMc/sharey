class PagesControllerController < ApplicationController
  def home
  end

  def my_friends
    matt = User.last
    @friends = Friend.where user:matt
  end

  def saved_items
  end

  def about
  end
end
