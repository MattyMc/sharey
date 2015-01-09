class Document < ActiveRecord::Base
  has_many :items
  belongs_to :originator, class_name: "User"

end
