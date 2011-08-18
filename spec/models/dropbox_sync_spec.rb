require 'spec_helper'

describe "DropboxSync" do
  describe "#prune" do
    let(:section_name) { 'print' }
    let!(:section) { Factory(:section, :name => section_name) }
    let!(:meta_path) { "/foo/bar/columbus-brewery-redesign.png" }
    let!(:unpruned_file) { Factory(:dropbox_file, :meta_path => meta_path, :section => section) }
    let!(:pruned_file) { Factory(:dropbox_file, :meta_path => "get_pruned.png", :section => section) }

    let(:meta) do
      [{:revision => '1041066003', :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "#{meta_path}", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false},
       {:revision => '1041066003', :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "some/other/path.png", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false}]
    end

    let(:session) { mock('session', :ls => meta) }

    let(:dropbox) do
      dropbox = DropboxSync.new(session, section_name)
      dropbox.meta = meta
      dropbox
    end

    it 'destroys files belonging to section not included in meta' do
      dropbox.prune
      DropboxFile.find_by_id(pruned_file).should be_nil
    end

    it 'does not destroy files belonging to section that are included in meta' do
      dropbox.prune
      DropboxFile.find(unpruned_file).should_not be_nil
    end
  end

  describe "#refresh" do
    let(:section_name) { 'print' }
    let(:revision) { '1' }
    let(:meta_path) { "columbus-brewery-redesign.png" }

    let(:meta) do
      [{:revision => revision, :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "/some/path#{meta_path}", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false}]
    end

    let(:session) { mock('session', :ls => meta, :download => 'content') }

    let(:dropbox) do
      dropbox = DropboxSync.new(session, section_name)
      dropbox.meta = meta
      dropbox
    end

    context "same revision" do
      let!(:up_to_date_file) { Factory(:dropbox_file, :revision => revision, :meta_path => meta_path) }

      it "takes no action" do
        session.should_not_receive(:download)
        dropbox.refresh
      end
    end

    context "different revision" do
      let!(:dropbox_file) { Factory(:dropbox_file, :revision => "!!#{revision}!!", :meta_path => meta_path) }

      it "replaces the file" do
        session.should_receive(:download).with(dropbox_file.meta_path)
        dropbox.refresh
      end
    end
  end

  describe "#download_new" do
    let(:section_name) { 'print' }
    let(:revision) { '1' }
    let(:meta_path) { "/foo/bar/columbus-brewery-redesign.png" }
    let(:new_meta_path) { "!#{meta_path}!" }

    let(:meta) do
      [{:revision => revision, :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => new_meta_path, :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false}]
    end

    let(:session) { mock('session', :ls => meta, :download => StringIO.open('spec/fixtures/random.png')) }

    let(:dropbox) do
      dropbox = DropboxSync.new(session, section_name)
      dropbox.meta = meta
      dropbox
    end

    context "the file belongs to an existing section" do
      let!(:section) { Factory(:section, :name => section_name) }

      it "attaches the file to the section" do
        dropbox.download_new
        dropbox_filepaths = section.dropbox_files.map(&:meta_path)
        dropbox_filepaths.should include new_meta_path
      end

      it "creates a file on the file system" do
        dropbox.download_new
        File.exists?("#{section.dropbox_files.first.attachment}")
      end
    end

    context "the file belongs to a new section" do
      it "attaches the file to the new item" do
        dropbox.download_new
        new_section = Section.find_by_name(section_name)
        dropbox_filepaths = new_section.dropbox_files.map(&:meta_path)
        dropbox_filepaths.should include new_meta_path
      end

      it "creates a file on the file system" do
        dropbox.download_new
        new_section = Section.find_by_name(section_name)
        File.exists?("#{new_section.dropbox_files.first.attachment}")
      end
    end
  end
end
