class DropboxFile < ActiveRecord::Base
  belongs_to :section

  attr_accessor :attachment
  mount_uploader :attachment, AttachmentUploader

  validates_presence_of :meta_path, :revision, :attachment

  def download(dropbox_session)
    file_content = dropbox_session.download(meta_path, :mode => :dropbox)
    self.attachment = DropboxStringIO.new(meta_path, file_content)
  end

  def replace(dropbox_session)
    file_content = dropbox_session.download(meta_path, :mode => :dropbox)
    File.open(attachment.path, 'w+b') do |file|
      file.write(file_content)
    end
  end
end
