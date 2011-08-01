class DropboxFile < ActiveRecord::Base
  belongs_to :item
# 
#   mount_uploader :attachment, AttachmentUploader

  validates :path, :presence => true, :uniqueness => true
  validates :revision, :presence => true
  validates :attachment, :presence => true

  def refresh(new_revision)
    if revision == new_revision
      download
    end
  end

  def download
  end
end
