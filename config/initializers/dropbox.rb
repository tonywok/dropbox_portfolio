DROPBOX_KEY    = '5ay3lmc3qp5mxmm'
DROPBOX_SECRET = 'eus14ampvo1931o'

class DropboxStringIO < StringIO
  attr_accessor :filepath

  def initialize(*args)
    super(*args[1..-1])
    @filepath = args[0]
  end

  def original_filename
    File.basename(filepath)
  end
end
