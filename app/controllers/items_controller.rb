class ItemsController < ApplicationController
  layout false  

  # Errors ------------------------------------------------------------------------------------
  class UserNotFound < StandardError 
    # def initialize(msg = "You've triggered a MyError")
    #   super
    # end
  end


  # -------------------------------------------------------------------------------------------
  # Actions -----------------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

  def create_or_update
    item = Item.create_or_update_from_item_params_and_user item_params, user
    render json:{modal: {headline: "Saved!", messages:item.messages } }, status: :ok
  rescue StandardError => e
    render json:{modal: {headline: "", messages:[e.message] } }, status: :bad_request
  end


  private

  # -------------------------------------------------------------------------------------------
  # Helper methods ----------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

  def user
    @user_from_session_cookie ||= User.find_by sharey_session_cookie:cookies["sharey_session_cookie"]
    raise UserNotFound, "Who are you, again?" if @user_from_session_cookie.nil?
    @user_from_session_cookie
  end

  def item_params
    params["item"]
  end
end
