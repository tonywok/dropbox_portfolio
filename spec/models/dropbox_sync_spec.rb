require 'spec_helper'

describe "DropboxSync" do
  describe "#prune" do
    let(:section_name) { 'print' }
    let!(:unpruned_meta_path) { "/foo/columbus-brewery-redesign.png" }
    let!(:pruned_meta_path) { "/foo/get_pruned.png" }
    let!(:section) { Factory.create(:section, :name          => section_name,
                                              :dropbox_files => [ Factory.build(:dropbox_file, :meta_path => unpruned_meta_path),
                                                                  Factory.build(:dropbox_file, :meta_path => pruned_meta_path) ]) }
    let(:remote_data) do
      { "name"          => "#{section_name}",
        "description"   => "lorem ipsum dolar",
        "dropbox_files" => "[{\"revision\":1041066054,\"thumb_exists\":true,\"bytes\":6646,\"modified\":\"2011-08-19T15:05:03-04:00\",\"path\":\"#{unpruned_meta_path}\",\"is_dir\":false,\"icon\":\"page_white_picture\",\"mime_type\":\"image/png\",\"size\":\"6.5KB\",\"directory?\":false},
                             {\"revision\":1041065999,\"thumb_exists\":true,\"bytes\":76278,\"modified\":\"2011-07-30T19:47:32-04:00\",\"path\":\"/test/mewithmustache.jpeg\",\"is_dir\":false,\"icon\":\"page_white_picture\",\"mime_type\":\"image/jpeg\",\"size\":\"74.5KB\",\"directory?\":false},
                             {\"revision\":1041066057,\"thumb_exists\":true,\"bytes\":567324,\"modified\":\"2011-08-20T12:15:16-04:00\",\"path\":\"/test/nancers.jpeg\",\"is_dir\":false,\"icon\":\"page_white_picture\",\"mime_type\":\"image/jpeg\",\"size\":\"554KB\",\"directory?\":false}]" }
    end

    let(:session) { mock('session') }
    let(:dropbox) { DropboxSync.new(session, remote_data) }

    it "destroys a section's dropbox files outside the set of remote dropbox files" do
      dropbox.prune
      DropboxFile.find_by_meta_path(pruned_meta_path).should be_nil
    end

    it 'does not destroy files belonging to section that are included in meta' do
      dropbox.prune
      DropboxFile.find_by_meta_path(unpruned_meta_path).should_not be_nil
    end
  end

  describe "#new_remote_files" do
    let(:section_name) { 'print' }
    let!(:up_to_date_revision) { "1" }
    let!(:out_of_date_revision) { "2" }
    let!(:section) { Factory.create(:section, :name          => section_name,
                                              :dropbox_files => [ Factory.build(:dropbox_file, :revision => up_to_date_revision),
                                                                  Factory.build(:dropbox_file, :revision => out_of_date_revision) ]) }
    let(:remote_data) do
      { "name"          => "#{section_name}",
        "description"   => "lorem ipsum dolar",
        "dropbox_files" => "[{\"revision\":#{up_to_date_revision},\"thumb_exists\":true,\"bytes\":76278,\"modified\":\"2011-07-30T19:47:32-04:00\",\"path\":\"/test/mewithmustache.jpeg\",\"is_dir\":false,\"icon\":\"page_white_picture\",\"mime_type\":\"image/jpeg\",\"size\":\"74.5KB\",\"directory?\":false},
                             {\"revision\":#{out_of_date_revision},\"thumb_exists\":true,\"bytes\":567324,\"modified\":\"2011-08-20T12:15:16-04:00\",\"path\":\"/test/nancers.jpeg\",\"is_dir\":false,\"icon\":\"page_white_picture\",\"mime_type\":\"image/jpeg\",\"size\":\"554KB\",\"directory?\":false}]" }
    end

    let(:session) { mock('session') }
    let(:dropbox) { DropboxSync.new(session, remote_data) }
    let(:remote_file_revisions) { dropbox.new_remote_files.map {|remote_file| remote_file["revision"] } }

    it "rejects remote dropbox files that are already up to date locally" do
      remote_file_revisions.should_not include(up_to_date_revision)
    end

    it "accepts remote dropbox files that are out of date locally" do
      remote_file_revisions.should_not include(out_of_date_revision)
    end
  end

  describe "#download" do
    let(:section_name) { 'print' }
    let!(:section) { Factory.build(:section, :name => section_name) }
    let(:remote_data) do
      { "name"          => "#{section_name}",
        "description"   => "lorem ipsum dolar",
        "dropbox_files" => "[{\"revision\":1041066054,\"thumb_exists\":true,\"bytes\":76278,\"modified\":\"2011-07-30T19:47:32-04:00\",\"path\":\"/test/mewithmustache.jpeg\",\"is_dir\":false,\"icon\":\"page_white_picture\",\"mime_type\":\"image/jpeg\",\"size\":\"74.5KB\",\"directory?\":false},
                             {\"revision\":1041065999,\"thumb_exists\":true,\"bytes\":567324,\"modified\":\"2011-08-20T12:15:16-04:00\",\"path\":\"/test/nancers.jpeg\",\"is_dir\":false,\"icon\":\"page_white_picture\",\"mime_type\":\"image/jpeg\",\"size\":\"554KB\",\"directory?\":false}]" }
    end
    let(:session) { mock('session', :download => "Remote Content") }
    let(:dropbox) { DropboxSync.new(session, remote_data) }

    it "adds the remote dropbox files to section " do
      new_dropbox_filepaths = dropbox.remote_dropbox_files.map { |rdf| rdf["path"] }
      dropbox.download(dropbox.remote_dropbox_files)

      section.dropbox_files.each do |dropbox_file|
        new_dropbox_filepaths.should include dropbox_file.meta_path
      end
    end

    it "creates a file on the file system" do
      dropbox.download(dropbox.remote_dropbox_files)

      section.dropbox_files.each do |dropbox_file|
        File.exists?("#{dropbox_file.attachment}").should be_true
      end
    end
  end
end
