# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  share_path         :string(255)
#  admin              :boolean         default(FALSE)
#

require 'digest'
class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation

  has_many :items, :dependent => :destroy

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name,  :presence => true,
                    :length   => { :maximum => 50}

  #When creating user directory, convert username to valid and unique filename
  validates :email, :presence   => true,
                    :format     => { :with => email_regex },
                    :uniqueness => { :case_sensitive => false}
  # Automatically create the virtual attribute 'password_confirmation'.
  validates :password, :presence     => true,
                       :confirmation => true,
                       :length       => { :within => 6..50}

  before_save :encrypt_password

  #Return true if the user's password matches the submitted password.
  def has_password?(submitted_password)
    #Compare encrypted_password with the encrypted version of
    #submitted_password.
    encrypted_password == encrypt(submitted_password)
  end

  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil  if user.nil?
    return user if user.has_password?(submitted_password)
    return nil
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user :nil
  end

  def create
    #create the share directory for this user
    self.share_path = make_share_path(email) 
    Dir.mkdir(self.share_path) if !File.directory?(self.share_path)
    super
  end

  def destroy
    #destroy the the share directory for this user
    if File.directory?(self.share_path)
      Dir.foreach(self.share_path) {
        |f| file_path = File.join(self.share_path,f)
        File.delete(file_path) if File.file?(file_path) }
    end
    Dir.rmdir(self.share_path)
    super
  end

  private

    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end

    def make_share_path(string)
      #To Do: ensure share_path is valid (path)
      Rails.root.join('users').join(string).to_s
    end
end
