require 'spec_helper'
require 'dummy_dropbox'

describe "Adding a dropbox" do
  before do
    DummyDropbox.root_path = '~/Dropbox/test'
    @dropbox_session = Dropbox::Session.new('key', 'secret')
    Admin::DropboxesController.any_instance.stub!(:dropbox_session).and_return(@dropbox_session)
  end

  describe "GET /admins/dropboxes/new" do
    let(:admin) { Factory(:admin) }

    before do
      visit new_admin_session_path
      fill_in "admin_email", :with => admin.email
      fill_in "admin_password", :with => admin.password
      click_button "Sign in"
    end

    # context "dropbox folder exists" do
    #   it "should check admin dropbox for that folder" do
    #     visit new_admin_dropbox_path
    #     fill_in "folder_name", :with => 'test'
    #     click_button 'Add'
    #     within('#dropbox_meta') do
    #       page.should have_content("Signed in successfully.")
    #     end
    #   end
    # end

    # it "should check admin dropbox for that folder", :js => true do
    #   visit new_admin_dropbox_path
    #   fill_in "folder_name", :with => 'dbfolderthatdoesntexist'
    #   click_button 'Add'
    #   page.should have_content("Dropbox folder not found")
    # end
  end
end
