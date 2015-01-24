class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user
  helper_method :user_signed_in?


  private

  def current_user
    begin
      @current_user ||= User.find(session[:current_user_id]) if session[:current_user_id]
    rescue Exception => e
      nil
    end
  end

  def user_signed_in?
    return true if current_user
  end
end
