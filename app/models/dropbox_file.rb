class DropboxFile < ActiveRecord::Base
  belongs_to :section

  mount_uploader :attachment, AttachmentUploader

  validates :path, :presence => true, :uniqueness => true
  validates :revision, :presence => true
  validates :item, :presence => true
  validates :attachment, :presence => true

  def download(dropbox_session)
    @attachment = dropbox_session.download(path)
  end

  def replace(dropbox_session)
    file_content = dropbox_session.download(path)
    File.open(attachment.path, 'w') do |f|
      f.write(file_content)
    end
  end
end
