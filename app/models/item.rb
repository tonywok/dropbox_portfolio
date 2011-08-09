class Item < ActiveRecord::Base
  has_many :dropbox_files, :dependent => :destroy

  validates :section, :presence => true
  validates :identifier, :presence => true

  before_validation :default_title

  private

  def default_title
    self.title = identifier.gsub("-", " ")
  end
end
