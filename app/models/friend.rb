class Friend < ActiveRecord::Base
  
  # Relationships -----------------------------------------------------------------------------
  belongs_to :user
  belongs_to :receiving_user, class_name: "User", foreign_key: "receiving_user_id"

  # Validations -------------------------------------------------------------------------------
  def check_user_and_receiving_user
    errors.add(:user, "can't be the same as receiving_user") if user_id == receiving_user_id
  end
  def check_first_character
    return errors.add(:tag, "must not be nil") unless !tag.nil? and !downcase_tag.nil?
    errors.add(:tag, "must begin with an @ symbol") unless tag.start_with?("@") and downcase_tag.start_with?("@")
  end
  validates :downcase_tag, :tag, :confirmed, presence: true
  validates :downcase_tag, :tag, format:{ without: /\s/ }
  validates :downcase_tag, :tag, format:{ without: /\./ }
  validates :downcase_tag, :tag, format:{ without: /\,/ }
  validates :user_id, uniqueness: { scope: :receiving_user_id }
  validate  :check_user_and_receiving_user
  validate  :check_first_character

  # -------------------------------------------------------------------------------------------
  # Class methods -----------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  
  def self.find_valid_friends_for_user user, tag_array
    return {},[] if user.nil? or tag_array.nil? or tag_array.empty?
    
    tag_array.map!(&:downcase).map!(&:strip)
    friends = Friend.where(user: user, downcase_tag:tag_array)

    missing_tags = []
    if friends.count < tag_array.count # find the tag taht was missing
      friend_tags = friends.pluck :downcase_tag
      missing_tags = tag_array - friend_tags
    end

    # Structure our return value as: {"@tag" => user, "@tag2" => user2, ...}
     
    tag_hash = {}
    friends.each {|f| tag_hash[f.tag] = f.receiving_user_id} unless friends.empty?
      
    return tag_hash, missing_tags
  end

  # Sorts the string into @tag_array and @description
  def self.parse_tag_array input_string
    ss = input_string.split(" ")
    word_array = []
    tag_array = []
    # Account for multiple tags with no spacing
    # If there's more than one '@' in a word, split the word
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
        temp[-1] = "" if temp[-1] == ","
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


end
