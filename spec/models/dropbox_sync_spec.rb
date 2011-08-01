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
    before do
      @expired_item = Factory(:item, :filename_identifier => 'not-in-meta', :section => section)
      @current_item = Factory(:item, :filename_identifier => 'bar', :section => section)
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

    it 'destroys items not included in parsed meta list' do
      dropbox.prune_items
      Item.find_by_id(@expired_item).should be_nil
    end

    it 'does not destroy items that match new dropbox metadata' do
      dropbox.prune_items
      Item.find(@current_item).should_not be_nil
    end
  end

  describe "#prune_dropbox_files" do
    before do
      @expired_file = Factory(:dropbox_file, :path => "/section_1/bar_the-very-hungry-caterpillar.png")
      @current_file = Factory(:dropbox_file, :path => "/section_1/bar_the-very-outofdate-facemonster.png")
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

    it 'destroys files not included in parsed meta list' do
      dropbox.prune_dropbox_files
      DropboxFile.find_by_id(@expired_file).should be_nil
    end

    it 'does not destroy files that match new dropobox metadata' do
      dropbox.prune_dropbox_files
      DropboxFile.find(@current_file).should_not be_nil
    end
  end

  describe "#prune" do
    before do
      @expired_item_with_file = Factory(:item, :filename_identifier => 'not-in-meta', :section => section)
      @expired_item_with_file.dropbox_files << Factory(:dropbox_file)
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
        dropbox_file = @expired_item_with_file.dropbox_files.first
        Item.find_by_id(@expired_item_with_file).should be_nil
        DropboxFile.find_by_id(dropbox_file).should be_nil
      end
    end
  end
end
