require 'spec_helper'

describe "DropboxSync" do
  describe "#prune" do
    let(:section_name) { 'print' }
    let!(:section) { Factory(:section, :name => section_name) }
    let!(:meta_path) { "/foo/bar/columbus-brewery-redesign.png" }
    let!(:unpruned_file) { Factory(:dropbox_file, :meta_path => meta_path, :section => section) }
    let!(:pruned_file) { Factory(:dropbox_file, :meta_path => "get_pruned.png", :section => section) }

    let(:meta) do
      [ OpenStruct.new(:revision => '1041066003', :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "#{meta_path}", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false),
        OpenStruct.new(:revision => '1041066003', :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "some/other/path.png", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false) ]
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
    let!(:meta_path) { "columbus-brewery-redesign.png" }

    let(:meta) do
      [ OpenStruct.new(:revision => revision, :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "/some/path#{meta_path}", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false) ]
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
end

  #     it "removes revised file from parsed meta collection" do
  #       dropbox.refresh
  #       files_by_item = dropbox.parsed_meta[identifier]
  #       files_by_item.should_not include dropbox_file.path
  #     end
  #   end

  # describe "#download_new" do
  #   let(:section) { 'section_1' }
  #   let(:revision) { '1041066003' }
  #   let(:identifier) { "book-covers" }
  #   let(:filename) { "the-very-hungry-catapillar.png" }
  #   let(:dropbox_filepath) { "#{section}/#{identifier}_#{filename}" }

  #   let(:meta) do
  #     [
  #       OpenStruct.new(:revision => revision, :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "#{dropbox_filepath}", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false),
  #     ]
  #   end

  #   let(:session) { mock('session', :ls => meta, :download => StringIO.open('spec/fixtures/random.png')) }
  #   let(:dropbox) { DropboxSync.new(session, section) }

  #   context "the file belongs to an existing item" do
  #     let!(:existing_item) do
  #       Factory(:item, :identifier => identifier)
  #     end

  #     it "attaches the file to the item" do
  #       dropbox.download_new
  #       item_file_paths = existing_item.dropbox_files.map(&:path)
  #       item_file_paths.should include dropbox_filepath
  #     end

  #     it "creates a file on the file system" do
  #       dropbox.download_new
  #       File.exists?("#{existing_item.dropbox_files.first.attachment}")
  #     end
  #   end

  #   context "the file belongs to a new item" do
  #     it "creates the new item" do
  #       dropbox.download_new
  #       Item.find_by_identifier(identifier).should_not be_nil
  #     end

  #     it "attaches the file to the new item" do
  #       dropbox.download_new
  #       Item.find_by_identifier(identifier).dropbox_files.collect(&:path).should include dropbox_filepath
  #     end

  #     it "creates a file on the file system" do
  #       dropbox.download_new
  #       new_item = Item.find_by_identifier(identifier)
  #       File.exists?("#{new_item.dropbox_files.first.attachment}")
  #     end
  #   end
  # end
  # end
