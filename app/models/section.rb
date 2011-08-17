class Section < ActiveRecord::Base
  has_many :dropbox_files
end
