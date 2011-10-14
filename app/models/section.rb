class Section < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, :use => :slugged

  has_many :dropbox_files, :dependent => :destroy

  validates_presence_of   :name, :dropbox_files
  validates_uniqueness_of :name
end
