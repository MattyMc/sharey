class Category < ActiveRecord::Base
  has_many :items
  belongs_to :user

  validates :name, :downcase_name, :user_id, presence: true
  validates :downcase_name, uniqueness: { scope: :user_id }

  # Only want to run this method for new records
  before_validation :set_downcase_name, on: :create

  def set_downcase_name
    self.name.strip! unless self.name.blank?
    self.downcase_name = self.name.downcase unless self.name.blank?
  end
end
