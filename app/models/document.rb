class Document < ActiveRecord::Base
  has_many :items
  belongs_to :originator, class_name: "User"

  validates :url, :originator_id, presence: true
  validates :url, uniqueness: true
end
