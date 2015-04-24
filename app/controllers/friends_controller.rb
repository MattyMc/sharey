class FriendsController < ApplicationController
  before_filter :verify_user, :only => [:update, :destroy] 
  
  # POST /friends
  # POST /friends.json
  def create
    friend = Friend.create_from_user_email_and_tag current_user, new_friend_params["email"], new_friend_params["tag"]
    redirect_to my_friends_path, notice: 'You made a new friend!'
  rescue StandardError => e
    flash[:alert] = e.record.errors.full_messages.join ", "
    redirect_to my_friends_path
  end

  # PATCH/PUT /friends/1
  # PATCH/PUT /friends/1.json
  def update
    @friend.confirmed ? @friend.update!(tag:friend_params["tag"]) : @friend.update!(tag:friend_params["tag"], confirmed: true)
    redirect_to my_friends_path, notice: "Updated the tag!"
  rescue StandardError => e
    flash[:alert] = e.record.errors.full_messages.join ", "
    redirect_to my_friends_path

    # respond_to do |format|
    #   if @friend.update(friend_params)
    #     format.html { redirect_to @friend, notice: 'Friend was successfully updated.' }
    #     format.json { render :show, status: :ok, location: @friend }
    #   else
    #     format.html { render :edit }
    #     format.json { render json: @friend.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /friends/1
  # DELETE /friends/1.json
  def destroy
    @friend.destroy! 
    redirect_to my_friends_path, notice: "Sharey ended your friendship. One less friend :("
  
  rescue StandardError => e
    flash[:alert] = e.record.errors.full_messages.join ", "
    redirect_to my_friends_path
  end

  private
    # White list certain attributes
    def friend_params
      params.require(:friend).permit(:tag, :email)
    end

    def new_friend_params
      params.permit(:tag, :email)
    end

    # Ensure user has permission
    def verify_user
      @friend = Friend.where(id: params[:id]).first
      if @friend.nil?
        redirect_to(my_friends_path, alert: "Error. Please try again.")
      elsif @friend.user != current_user
        redirect_to(my_friends_path, alert: "You are not authorized to do that. Please login.")
      end
    end
end
