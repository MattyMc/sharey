class UnregisteredUser < ActiveRecord::Base
  has_many :items, as: :user
  has_many :usage_datum, as: :user
  has_many :friends_with_me, class_name: "Friend", as: :receiving_user
  has_many :friends, as: :user

  validates :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i  # Validates email format

end
