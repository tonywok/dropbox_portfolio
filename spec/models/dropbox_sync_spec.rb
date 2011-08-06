require 'spec_helper'

describe "DropboxSync" do
  describe '#parse' do
    let(:section) { 'section_1' }

    let(:meta) do
      [
        OpenStruct.new(:revision => '1041066003', :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "/section_1/book-covers_the-very-hungry-caterpillar.png", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false),
        OpenStruct.new(:revision => '1041066005', :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "/section_1/book-covers_see-spot-run.png", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false),
        OpenStruct.new(:revision => '1041065999', :thumb_exists => true, :bytes => 76278, :modified => '2011-07-30 19:47:32 -0400', :path => "/section_1/beer-labels_natural-light.jpeg", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/jpeg", :size => "74.5KB", :directory? => false),
      ]
    end

    let(:session) { mock('session', :ls => meta) }
    let(:dropbox) { DropboxSync.new(session, section) }

    it 'returns hash with item keys' do
      dropbox.parse.keys.should include :'book-covers'
      dropbox.parse.keys.should include :'beer-labels'
    end

    it 'has has files associated to item keys' do
      dropbox.parse[:'book-covers'].should include '/section_1/book-covers_see-spot-run.png'
      dropbox.parse[:'book-covers'].should include '/section_1/book-covers_the-very-hungry-caterpillar.png'
      dropbox.parse[:'beer-labels'].should include '/section_1/beer-labels_natural-light.jpeg'
    end
  end

  describe "#prune_items" do
    let!(:expired_item) { Factory(:item, :filename_identifier => 'not-in-meta', :section => section) }
    let!(:current_item) { Factory(:item, :filename_identifier => 'bar', :section => section) }

    let(:section) { 'section_1' }

    let(:meta) do
      [
        OpenStruct.new(:revision => '1041066003', :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "/section_1/bar_the-very-hungry-caterpillar.png", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false),
        OpenStruct.new(:revision => '1041066003', :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "/section_1/foo_the-very-hungry-facemonster.png", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false),
      ]
    end

    let(:session) { mock('session', :ls => meta) }
    let(:dropbox) { DropboxSync.new(session, section) }

    it 'destroys items not included in parsed meta list' do
      dropbox.prune_items
      Item.find_by_id(expired_item).should be_nil
    end

    it 'does not destroy items that match new dropbox metadata' do
      dropbox.prune_items
      Item.find(current_item).should_not be_nil
    end
  end

  describe "#prune_dropbox_files" do
    let!(:expired_file) { Factory(:dropbox_file, :path => "/section_1/bar_the-very-hungry-caterpillar.png") }
    let!(:current_file) { Factory(:dropbox_file, :path => "/section_1/bar_the-very-outofdate-facemonster.png") }

    let(:section) { 'section_1' }

    let(:meta) do
      [
        OpenStruct.new(:revision => '1041066003', :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "/section_1/bar_the-very-hungry-caterpillar.png", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false),
        OpenStruct.new(:revision => '1041066003', :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "/section_1/foo_the-very-hungry-facemonster.png", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false),
      ]
    end

    let(:session) { mock('session', :ls => meta) }
    let(:dropbox) { DropboxSync.new(session, section) }

    it 'destroys files not included in parsed meta list' do
      dropbox.prune_dropbox_files
      DropboxFile.find_by_id(expired_file).should be_nil
    end

    it 'does not destroy files that match new dropobox metadata' do
      dropbox.prune_dropbox_files
      DropboxFile.find(current_file).should_not be_nil
    end
  end

  describe "#prune" do
    let!(:expired_item_with_file) do
      item = Factory(:item, :filename_identifier => 'not-in-meta', :section => section)
      item.dropbox_files << Factory(:dropbox_file)
      item
    end

    let(:section) { 'section_1' }

    let(:meta) do
      [
        OpenStruct.new(:revision => '1041066003', :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "/section_1/bar_the-very-hungry-caterpillar.png", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false),
        OpenStruct.new(:revision => '1041066003', :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "/section_1/foo_the-very-hungry-facemonster.png", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false),
      ]
    end

    let(:session) { mock('session', :ls => meta) }
    let(:dropbox) { DropboxSync.new(session, section) }

    context "when an expired item has dropbox files" do
      it "prunes out of date items along with all of it's files" do
        dropbox.prune
        dropbox_file = expired_item_with_file.dropbox_files.first
        Item.find_by_id(expired_item_with_file).should be_nil
        DropboxFile.find_by_id(dropbox_file).should be_nil
      end
    end
  end

  describe "#parse_item" do
    let(:section) { 'section_1' }

    let(:meta) do
      [
        OpenStruct.new(:revision => '1041066003', :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "/section_1/book-covers_the-very-hungry-caterpillar.png", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false),
      ]
    end

    let(:session) { mock('session', :ls => meta) }
    let(:dropbox) { DropboxSync.new(session, section) }

    it "pulls the item out of the item name" do
      filename = "/foo/bar/stuff/my-item_my-name.png"
      dropbox.parse_item(filename).should == :'my-item'
    end

    it "pulls the item out of the item name" do
      filename = "/foo/bar/stuff/my-item.png"
      dropbox.parse_item(filename).should == :'my-item'
    end
  end

  describe "#refresh" do
    let(:section) { 'section_1' }
    let(:revision) { '1041066003' }
    let(:filename_identifier) { "book-covers" }
    let(:dropbox_filepath) { "#{section}/#{filename_identifier}_the-very-hungry-catapillar.png" }

    let(:meta) do
      [
        OpenStruct.new(:revision => revision, :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "#{dropbox_filepath}", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false),
      ]
    end

    let!(:unrevised_item) { Factory(:item) }
    let(:session) { mock('session', :ls => meta, :download => 'content') }
    let(:dropbox) { DropboxSync.new(session, section) }

    context "same revision" do
      let!(:dropbox_file) do
        Factory(:dropbox_file,
                :revision => revision,
                :path => dropbox_filepath,
                :item => Factory(:item, :filename_identifier => filename_identifier))
      end

      it "has file in parsed meta collection" do
        dropbox.parsed_meta[filename_identifier.to_sym].should include dropbox_file.path
      end

      it "takes no action" do
        session.should_not_receive(:download)
        dropbox.refresh
      end

      it "removes up to date file from parsed meta collection" do 
        dropbox.refresh
        files_by_item = dropbox.parsed_meta[filename_identifier.to_sym]
        files_by_item.should_not include dropbox_file.path
      end
    end

    context "different revision" do
      let!(:dropbox_file) do
        Factory(:dropbox_file,
                :revision => "!!#{revision}!!",
                :path => dropbox_filepath,
                :item => Factory(:item, :filename_identifier => filename_identifier))
      end

      it "replaces the file" do
        session.should_receive(:download).with(dropbox_file.path)
        dropbox.refresh
      end

      it "removes revised file from parsed meta collection" do 
        dropbox.refresh
        files_by_item = dropbox.parsed_meta[filename_identifier.to_sym]
        files_by_item.should_not include dropbox_file.path
      end
    end
  end

  describe "#download_new" do
    let(:section) { 'section_1' }
    let(:revision) { '1041066003' }

    let(:meta) do
      [
        OpenStruct.new(:revision => revision, :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "/section_1/book-covers_the-very-hungry-caterpillar.png", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false),
        OpenStruct.new(:revision => revision, :thumb_exists => true, :bytes => 5161,  :modified => '2011-07-31 18:04:59 -0400', :path => "/section_1/album-art_fill-and-the-wailers.png", :is_dir => false, :icon => "page_white_picture", :mime_type => "image/png", :size => "5KB", :directory => false),
      ]
    end

    let!(:existing_item) { Factory(:item, :filename_identifier => 'book_labels') }

    let(:session) { mock('session', :ls => meta, :download => 'content') }
    let(:dropbox) { DropboxSync.new(session, section) }

    context "the file belongs to an existing item" do
      it "attaches the file to the item"
    end

    context "the file belongs to a new item" do
      it "creates the new item"

      it "attaches the file to the new item"
    end
  end
end
