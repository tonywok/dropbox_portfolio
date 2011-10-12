class Section < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, :use => :slugged

  has_many :dropbox_files, :dependent => :destroy

  validates :dropbox_files, :presence => true
  validates :name, :uniqueness => true,
                   :presence   => true
end
