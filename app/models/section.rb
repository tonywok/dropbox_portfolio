class Section < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, :use => :slugged

  has_many :dropbox_files

  validates_presence_of :name
end
