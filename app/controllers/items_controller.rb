class ItemsController < ApplicationController
  
  # Errors ------------------------------------------------------------------------------------
  class UserNotFound < StandardError; end


  # -------------------------------------------------------------------------------------------
  # Actions -----------------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

  def create_or_update
    Item.create_or_update_from_item_params_and_user item_params, user
  end


  private

  # -------------------------------------------------------------------------------------------
  # Helper methods ----------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

  def user
    @user_from_session_cookie ||= User.find_by sharey_session_cookie:cookies["sharey_session_cookie"]
    raise UserNotFound if @user_from_session_cookie.nil?
    @user_from_session_cookie
  end

  def item_params
    params["item"]
  end
end
