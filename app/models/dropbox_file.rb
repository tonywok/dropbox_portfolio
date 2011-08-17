class DropboxFile < ActiveRecord::Base
  belongs_to :section

  attr_accessor :attachment
  mount_uploader :attachment, AttachmentUploader

  validates_presence_of :meta_path, :revision, :section, :attachment

  def download(dropbox_session)
    self.attachment = dropbox_session.download(meta_path)
  end

  def replace(dropbox_session)
    file_content = dropbox_session.download(meta_path)
    File.open(attachment.path, 'w') do |f|
      f.write(file_content)
    end
  end
end
