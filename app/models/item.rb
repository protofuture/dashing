class Item < ActiveRecord::Base
  attr_accessible :shared

  belongs_to :user

  validates :user_id, :presence => true
#validates :private_path, :presence => true

end
