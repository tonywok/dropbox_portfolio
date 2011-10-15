require 'spec_helper'

describe Section do
  describe "#public_dir" do
    let(:section) { Factory(:section, :name => 'test', :dropbox_files => [Factory.build(:dropbox_file)]) }
    it "is the location of the section relative to Rails.root/public/" do
      section.public_dir.should == "portfolio/test/"
    end
  end

  describe "#remove_directory" do
    let(:section) { Factory(:section, :name => "test", :dropbox_files => [Factory.build(:dropbox_file)]) }

    it "cleans up after itself when destroyed" do
      Dir.should_receive(:rmdir).with(/#{Rails.root}\/public\/*/).twice # addtional time for rmdir-ing cache dir?
      section.destroy
    end
  end
end
