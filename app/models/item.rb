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
  attr_accessor :file
  attr_accessible :shared, :file, :private_path

  belongs_to :user

  validates :user_id, :presence => true
#  validates :shared, :presence => true
  validates :file, :presence => true

  default_scope :order => 'items.created_at DESC'

  def create
    #set the file path
    set_path
    #save the uploaded file
    file_save
    super
  end

  def destroy
    File.delete(full_path) if File.file?(full_path)
  super
  end

  def file_save
    # write the file
    File.open(full_path, "wb") { |f| f.write(file.read) }
  end

  def set_path
    self.private_path = file.original_filename
  end

  def full_path
    File.join(self.user.share_path,private_path)
  end
end
