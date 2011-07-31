require 'spec_helper'
require 'dummy_dropbox'

describe "Adding a dropbox" do
  before do
    DummyDropbox.root_path = '~/Dropbox/test'
    @dropbox_session = Dropbox::Session.new('key', 'secret')
    Admin::DropboxesController.any_instance.stub!(:dropbox_session).and_return(@dropbox_session)
  end

  context "logged in as admin" do
    let(:admin) { Factory(:admin) }

    before do
      visit new_admin_session_path
      fill_in "admin_email", :with => admin.email
      fill_in "admin_password", :with => admin.password
      click_button "Sign in"
    end

    describe "POST /admins/dropboxes" do
      it "should check admin dropbox for that folder" do
        session_mock = mock('Dropbox::Session')
        session_mock.should_receive(:list).once.with('test')
        visit new_admin_dropbox_path
        fill_in "folder_name", :with => 'test'
        click_button 'Sync'
      end
    end
  end
end
