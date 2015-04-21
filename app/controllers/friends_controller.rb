class FriendsController < ApplicationController
  
  # POST /friends
  # POST /friends.json
  def create
    @friend = Friend.create_from_user_email_and_tag current_user, friend_params["email"], friend_params["tag"]

    respond_to do |format|
      if @friend.save
        format.html { redirect_to my_friends_path, notice: 'Friend was successfully created.' }
        format.json { render :show, status: :created, location: @friend }
      else
        format.html { render json: @friend.errors, status: :unprocessable_entity  }
        format.json { render json: @friend.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /friends/1
  # PATCH/PUT /friends/1.json
  def update
  end

  # DELETE /friends/1
  # DELETE /friends/1.json
  def destroy
  end

  private
    # White list certain attributes
    def friend_params
      params.require(:friend).permit(:tag, :email)
    end
end
