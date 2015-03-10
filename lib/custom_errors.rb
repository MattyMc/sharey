module CustomErrors
  # Test coverage is in test/modules/custom_errors.rb

  # NOTE!! The following code must be added to config/environments/development.rb, test.rb and production.rb
  #           be sure to change the url appropriately
  # Add URL host path for testing:
  # config.after_initialize do 
  #   Rails.application.routes.default_url_options[:host] = "https://sharey.ngrok.com"
  # end

  # TODO: Write a test to ensure that if the user is not found,
  #         a link to the login URL will be contained somewhere in 
  #         one of the response messages.
  # TODO: Define a login URL that's different from root_url in UserNotFound

  # BIG TODO: Create a standard format for errors, so that each error has a type attribute that is:
  #             1. modal  (where a modal appears, with desired attributes)
  #             2. flash  (where a flash message appears, with attributes)
  #             3. inline (where the item will be replaced, such as the deleted action)
  #             3. items  (where the items are returned as JSON)
  #     Afterwards, re-write the front-end application to parse messages apppropriately with
  #        a standardized AJAX response function
  #     BONUS: Write a helper module for testing
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
      { "type" => "modal", "data" => @message }
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
      { "type" => "modal", "data" => @message }
    end
  end

  class NoItemsFound < StandardError
    # TODO: Make the response to this a flash message
    include Rails.application.routes.url_helpers

    def initialize
      @message = {}
      @message["messages"] = []

      @message["heading"] = "Ummm..."
      @message["subheading"] = "You haven't saved anything yet"
      @message["messages"] << "Maybe you were expecting something from a friend?"
      @message["messages"] << "Sharey'ing is caring"
    end

    def modal_response
      { "type" => "modal", "data" => @message }
    end
  end

  # Gets thrown when user tries to delete an item with :id that does not belong to him/her
  class ItemNotFoundForUser < StandardError
    include Rails.application.routes.url_helpers

    def initialize
      @message = {}
      @message["messages"] = []

      @message["heading"] = "You can't delete that!"
      @message["subheading"] = "There are a few possible reasons why:"
      @message["messages"] << "You need to login again."
      @message["messages"] << "You're a hacker trying to delete someone else's shit... you bastard."
      @message["messages"] << "Our server broke... which wouldn't be surprising, since we got <a href='http://glennobrien.com/wp-content/uploads/2011/12/Monkeys-typing.jpg'>these guys</a> to code Sharey."
    end

    def modal_response
      { "type" => "modal", "data" => @message }
    end
  end

end