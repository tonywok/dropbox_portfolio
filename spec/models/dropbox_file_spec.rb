require 'spec_helper'

describe DropboxFile do
  describe "#replace" do
    let(:item) { Factory.create(:item) }
    let(:file) { Factory.create(:dropbox_file, :item => item) }

    it 'downloads the file from dropbox' do
      dropbox_session = mock('session')
      dropbox_session.should_receive(:download)
      file.replace(dropbox_session)
    end

    it 'writes the new file' do
      content = rand(99**9)
      dropbox_session = mock('session', :download => content.to_s)
      file.replace(dropbox_session)
      File.read(file.attachment.path).should == content.to_s
    end
  end
end
