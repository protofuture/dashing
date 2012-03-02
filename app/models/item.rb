# == Schema Information
#
# Table name: items
#
#  id           :integer         not null, primary key
#  private_path :string(255)
#  user_id      :integer
#  shared       :boolean
#  created_at   :datetime
#  updated_at   :datetime
#

class Item < ActiveRecord::Base
  attr_accessible :shared

  belongs_to :user

  validates :user_id, :presence => true
#validates :private_path, :presence => true

end
