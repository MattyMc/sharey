require 'custom_errors'

class ItemsController < ApplicationController
  include CustomErrors

  skip_before_filter :verify_authenticity_token, :only => [:create_or_update, :number_of_unviewed_items, :index, :destroy] # Avoids CSRF check
  layout false  

  

  # -------------------------------------------------------------------------------------------
  # Actions -----------------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  
  # TODO: Make sure if a user deletes an item and then resaves it, that it becomes "undeleted"
  #         with the new description

  # TODO: Build in a check to make sure the error is a modal, and not from ActiveRecord 
  #         where e.modal_response would not be defined
  def index
    render json:user.last_n_items(20), status: :ok
  rescue StandardError => e
    render json:e.modal_response, status: :bad_request
  end

  def create_or_update
    item = Item.create_or_update_from_item_params_and_user item_params, user

    # logger.warn item.modal_response 
    render json:item.modal_response, status: :ok
  rescue StandardError => e
    # logger.warn e.modal_response
    render json:e.modal_response, status: :bad_request
  end

  def destroy
    user.destroy_item params[:id]

    render json:{"deleted" => true}, status: :ok
  rescue StandardError => e
    render json:e.modal_response, status: :bad_request
  end

  def show
    item = user.items.where(id: params[:id]).first
    raise ItemNotFoundForUser if item.nil?
    item.clicked
    
    render json:{"clicked" => true}, status: :ok
  rescue StandardError => e
    render json:e.modal_response, status: :bad_request
  end

  def number_of_unviewed_items
    unviewed_item_count = user.get_number_of_unviewed_items
    render json:unviewed_item_count
  rescue StandardError => e
    render nothing: true, status: :bad_request
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
