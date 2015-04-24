class Friend < ActiveRecord::Base
  
  # Relationships -----------------------------------------------------------------------------
  belongs_to :user
  belongs_to :receiving_user, polymorphic: true

  # Validations -------------------------------------------------------------------------------
  def check_user_and_receiving_user
    errors.add(:user, "can't be the same as receiving_user") if user_id == receiving_user_id
  end
  def check_first_character
    return true unless confirmed
    return errors.add(:tag, "must not be empty") unless !tag.nil?
    errors.add(:tag, "must begin with an @ symbol") unless tag.start_with?("@") and tag.length > 1
  end
  validates :user, :receiving_user, presence: true
  validates :tag, format:{ without: /\s/ }
  validates :tag, format:{ without: /\./ }
  validates :tag, format:{ without: /\,/ }
  validates :user_id, uniqueness: { scope: [:receiving_user_id, :receiving_user_type] }
  validates :tag,  uniqueness: { case_sensitive: false, scope: :user_id }
  validates :confirmed, inclusion: [true, false]
  validate  :check_user_and_receiving_user
  validate  :check_first_character

  before_validation(on: :update) do 
    self.tag = self.tag.strip
  end

  # -------------------------------------------------------------------------------------------
  # Class methods -----------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  
  def self.create_from_user_email_and_tag user, email, tag
    # Look to see if email exists in Users (downcase email)
    rec_user = User.where("lower(email) = ?", email.downcase).first

    # If not, does it exist in UnregisteredUsers?
    rec_user = UnregisteredUser.where("lower(email) = ?", email.downcase).first if rec_user.nil?
    rec_user = UnregisteredUser.create!(email: email) if rec_user.nil?

    Friend.create! user:user, receiving_user:rec_user, tag:tag, confirmed: true
  end

  def self.find_valid_friends_for_user user, tag_array
    return {},[] if user.nil? or tag_array.nil? or tag_array.empty?
    
    tag_array.map!(&:downcase).map!(&:strip)
    # TODO: Fix the line below to avoid the N+1 problem (find a way to eager load a polymorphic relationship)
    friends = Friend.where(user: user).where("lower(tag) IN (?)", tag_array)

    missing_tags = []
    if friends.count < tag_array.count # find the tags that were missing
      friend_tags = friends.pluck :tag
      missing_tags = tag_array - friend_tags.map!(&:downcase).map!(&:strip)
    end

    # Structure our return value as: {"@tag" => receiving_user, "@tag2" => receiving_user2, ...}
     
    tag_hash = {}
    friends.each {|f| tag_hash[f.tag] = f.receiving_user} unless friends.empty?
      
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
