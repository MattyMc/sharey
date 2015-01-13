class Category < ActiveRecord::Base
  
  # Relationships -----------------------------------------------------------------------------
  belongs_to :user
  has_many :items

  # Validations -------------------------------------------------------------------------------
  validates :name, :downcase_name, :user_id, presence: true
  validates :downcase_name, uniqueness: { scope: :user_id }

  # Filters -----------------------------------------------------------------------------------
  before_validation :set_downcase_name, on: :create # sets downcase_name for new attributes


  # -------------------------------------------------------------------------------------------
  # Class methods -----------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

  def self.first_or_initialize_with_name_and_user name, user
    return nil if name.blank?

    category = Category.where(
      downcase_name: name.strip.downcase,
      user: user).first_or_initialize

    if category.new_record?  
      category.name = name 
      category.save! 
    end
    
    category
  end


  private

  # -------------------------------------------------------------------------------------------
  # Helper methods ----------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

  def set_downcase_name
    self.name.strip! unless self.name.blank?
    self.downcase_name = self.name.downcase unless self.name.blank?
  end
end
