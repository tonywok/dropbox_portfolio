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
                             {\"revision\":1041066057,\"thumb_exists\":true,\"bytes\":567324,\"modified\":\"2011-08-20T12:15:16-04:00\",\"path\":\"/test/nancers.jpeg\",\"is_dir\":false,\"icon\":\"page_white_picture\",\"mime_type\":\"image/jpeg\",\"size\":\"554KB\",\"directory?\":false}]"
      }
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

  describe "#download_new" do
    let(:section_name) { 'print' }
    let(:revision) { '1' }
    let(:meta_path) { "/foo/bar/columbus-brewery-redesign.png" }
    let(:new_meta_path) { "!#{meta_path}" }

    let(:meta) do
      [{"revision" => revision, "thumb_exists" => true, "bytes" => 5161,  "modified" => '2011-07-31 18:04:59 -0400', "path" => new_meta_path, "is_dir" => false, "icon" => "page_white_picture", "mime_type" => "image/png", "size" => "5KB", "directory" => false}]
    end

    let(:session) { mock('session', :ls => meta, :download => "Content") }

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
