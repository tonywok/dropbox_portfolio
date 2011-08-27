class Section < ActiveRecord::Base
  has_many :dropbox_files

  validates_presence_of :name
end
