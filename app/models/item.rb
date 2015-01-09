class Item < ActiveRecord::Base
  belongs_to :user
  belongs_to :document
  belongs_to :category
  has_one :usage_datum
  belongs_to :from_user, class_name: "User", foreign_key: "from_user_id"
end
