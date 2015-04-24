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


  # A method for pulling down data into JSON, to later push back up
  def retrieve_all_records_from
    params.require(:model)
    model_name = params["model"].camelize
    model = model_name.constantize

    records = model.all.map(&:attributes)

    # Add the missing attributes
    if (model_name == "Friend") 
      records.map! do |r|
        r.delete "downcase_tag"
        r["user_type"] = "User"
        r["receiving_user_type"] = "User"
        r
      end
    elsif (model_name == "Item")
      records.map! do |r|
        r["user_type"] = "User"
        r["description"] = r["description"].gsub("'", "\'")
        r
      end
    end

    response_text = "temp = JSON.parse('#{records.to_json}')\n\n"
    # Run temp.map do |t| User.create t end
    render text:response_text
  end
end
