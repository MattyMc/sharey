module ItemMessages
  def modal_response
    {modal: 
      {
        headline: self.headline,
        messages: self.messages
      }
    }.with_indifferent_access
  end

  # self.notes:
  #   tagged_users:        []
  #   missing_tags:        []
  #   already_saved:       []
  #   already_shared_with: []
  #   new_item:            true | false
  def headline
    response = self.notes["new_item"] ? "Saved" : "Updated"
    response += self.notes["tagged_users"].empty? ? "!" : " and Shared!"
    response
  end

  def messages
    m = []
    m << self.missing_tags_message unless self.notes["tagged_users"].empty?
    m << self.tagged_users_message unless self.notes["tagged_users"].empty?
    m << self.already_shared_with_message unless self.notes["already_shared_with"].empty?
    m << self.already_saved_message unless self.notes["already_saved"].empty?
    m << self.success_message if m.length == 0
    return m
  end

  # -------------------------------------------------------------------------------------------
  # Tag Messages ------------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------
  # TODO: Find a way to randomize these messages and make them hilarious

  def missing_tags_message
    tags = self.notes["missing_tags"]
    "Sharey couldn't find any tags defined for " + format_list(tags, "or")
  end

  def tagged_users_message
    tags = self.notes["tagged_users"]
    "You just Sharey'd this with " + format_list(tags, "and")
  end

  def already_shared_with_message
    tags = self.notes["already_shared_with"]
    "You've already shared this with " + format_list(tags, "and")
  end

  def already_saved_message
    tags = self.notes["already_saved"]
    temp = tags.count == 1 ? "has" : "have"
    format_list(tags,"and") + " already #{temp} this item saved!"
  end

  def success_message
    new_item = self.notes["new_item"]
    return "Our tiny elves are gently placing this website in a secure place for you." if new_item 
    return "You already had this one saved, so we updated the category and description for you." unless new_item
  end

  # -------------------------------------------------------------------------------------------
  # Helpers -----------------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------

  def format_list tag_array, divider
    tag_array_count = tag_array.count

    return tag_array[0] if tag_array_count == 1
    return tag_array.join(" #{divider} ") if tag_array_count == 2
    return tag_array[0..-2].join(", ") + ", #{divider} " + tag_array.last if tag_array_count > 2
  end
end