class DropboxFile < ActiveRecord::Base
  belongs_to :section

  attr_accessor :attachment
  mount_uploader :attachment, AttachmentUploader

  validates_presence_of :meta_path, :revision, :section, :attachment

  def download(dropbox_session)
    file_as_string = dropbox_session.download(meta_path, :mode => :dropbox)
    self.attachment = DropboxStringIO.new(meta_path, file_as_string)
  end

  def replace(dropbox_session)
    file_content = dropbox_session.download(meta_path, :mode => :dropbox)
    File.open(attachment.path, 'w') do |f|
      f.write(file_content)
    end
  end
end
