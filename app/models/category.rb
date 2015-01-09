class Category < ActiveRecord::Base
  has_many :items

  validates :name, :low_case_name, presence: true
end
