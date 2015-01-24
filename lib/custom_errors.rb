module CustomErrors
  # Test coverage is in test/modules/custom_errors.rb

  # TODO: Write a test to ensure that if the user is not found,
  #         a link to the login URL will be contained somewhere in 
  #         one of the response messages.
  # TODO: Define a login URL that's different from root_url in UserNotFound
  class UserNotFound < StandardError
    include Rails.application.routes.url_helpers

    def initialize
      @message = {}
      @message["messages"] = []

      @message["heading"] = "How could anyone forget you?"
      @message["subheading"] = "Well, Sharey did..."
      @message["messages"] << "Please take a moment to login <a href='#{root_url}'>here</a>"
    end

    def modal_response
      { "modal" => @message }
    end
  end
  

  class InvalidItemParams < StandardError
    include Rails.application.routes.url_helpers

    def initialize
      @message = {}
      @message["messages"] = []

      @message["heading"] = "What was THAT?!"
      @message["subheading"] = "This didn't get saved or shared..."
      @message["messages"] << "You need to fill out some sort of description"
      @message["messages"] << "How else could you find it later?"
    end

    def modal_response
      { "modal" => @message }
    end
  end

end