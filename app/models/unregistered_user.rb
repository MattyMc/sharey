class UnregisteredUser < ActiveRecord::Base
  has_many :items, as: :user
  has_many :usage_data, as: :user
  # has_many :friends, as: :receiving_user

  validates :email, presence: true

end
