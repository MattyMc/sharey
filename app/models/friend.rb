class Friend < ActiveRecord::Base
  
  # Relationships -----------------------------------------------------------------------------
  belongs_to :user
  belongs_to :receiving_user, class_name: "User", foreign_key: "receiving_user_id"

  # Validations -------------------------------------------------------------------------------
  def check_user_and_receiving_user
    errors.add(:user, "can't be the same as receiving_user") if user_id == receiving_user_id
  end
  validates :downcase_tag, :tag, :confirmed, presence: true
  validates :downcase_tag, :tag, format:{ without: /\s/ }
  validates :user_id, uniqueness: { scope: :receiving_user_id }
  validate  :check_user_and_receiving_user


  # -------------------------------------------------------------------------------------------
  # Class methods -----------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  
  def self.find_valid_friends_for_user user, tag_array
    return nil if user.nil? or tag_array.nil? or tag_array.empty?
    
    tag_array.map!(&:downcase).map!(&:strip)
    friends = Friend.where(user: user, downcase_tag:tag_array)

    if friends.count < tag_array.count # find the tag taht was missing
      friend_tags = friends.pluck :downcase_tag
      missing_tags = format_error_message(tag_array - friend_tags)
    end

    return friends.map{|u| u.receiving_user_id}, missing_tags
  end

  # Sorts the string into @tag_array and @description
  def self.parse_tag_array input_string
    ss = input_string.split(" ")
    word_array = []
    tag_array = []
    # Account for multiple tags with no spacing
    (0..ss.length-1).each do |i|

      if ss[i].count("@") > 1
        ss[i] = ss[i].split("").map!.with_index { |letter, j|
          if letter == "@" and j > 0
            letter = " @"
          else
            letter
          end
        }
        ss[i] = ss[i].join

      end

    end

    ss = ss.join(" ").split(" ")
    ss.each do |temp|
      if (temp.index("@"))
        tag_array += [temp]
      else
        word_array += [temp]
      end
    end
    description = word_array.join (" ")
    tag_array = tag_array.uniq - ["@"] # Remove duplicates and empty tags, ie "@"
    return description, tag_array
    # puts "Tag Array:"
    # puts @tag_array
    # puts "Description:"
    # puts @description
    # parseTagArray "@flying billy bishop @goes@to@war mofo!"
  end

  private

  def self.format_error_message tag_array
    message_prefix = "Sharey couldn't find any tags named "
    tag_array_count = tag_array.count

    return message_prefix + tag_array[0] if tag_array_count == 1
    return message_prefix + tag_array.join(" or ") if tag_array_count == 2
    return message_prefix + tag_array[0..-2].join(", ") + ", or " + tag_array.last if tag_array_count > 2
  end
end
