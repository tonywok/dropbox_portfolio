class Section < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, :use => :slugged

  has_many :dropbox_files, :dependent => :destroy

  after_destroy :remove_directory

  validates_presence_of   :name, :dropbox_files
  validates_uniqueness_of :name

  def remove_directory
    Dir.rmdir("#{Rails.root}/public/#{public_dir}")
  end

  def public_dir
    "portfolio/#{friendly_id.to_s.underscore}/"
  end
end
