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
  # TODO: Make sure if a user deletes an item and then resaves it, that it becomes "undeleted"

  def create_or_update
    item = Item.create_or_update_from_item_params_and_user item_params, user
    render json:item.modal_response, status: :ok
  rescue StandardError => e
    # TODO: Help generate better error responses
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
