class Item < ActiveRecord::Base
  has_many :dropbox_files, :dependent => :destroy

  validates :title, :presence => true
  validates :section, :presence => true
  validates :identifier, :presence => true
end
