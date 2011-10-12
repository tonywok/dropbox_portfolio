class Section < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, :use => :slugged

  has_many :dropbox_files

  validates :name, :presence   => true,
                   :uniqueness => true
  validates :dropbox_files, :presence => true
end
