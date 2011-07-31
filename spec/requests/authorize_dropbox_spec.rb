require 'spec_helper'

describe "Authorizing a drop account" do
  describe "GET /authorize_dropboxes" do
    context "logged in as admin" do
      let(:admin) { Factory(:admin) }

      before do
        visit new_admin_session_path
        fill_in "admin_email", :with => admin.email
        fill_in "admin_password", :with => admin.password
        click_button "Sign in"
      end

      context "admin has not yet authorized dropbox" do
        before { visit '/admin/dropboxes/new' }

        context "admin has a dropbox account" do
          it "links the two accounts" do
            click_link 'authorize'
          end
        end

        context "admin does not have a dropbox account" do
          pending
        end
      end
    end

    context "not logged in as admin" do
      before { visit '/admin/dropboxes/new' }

      it "does not allow url hack" do
        page.current_path.should == new_admin_session_path
      end

      it "informs the user about the failure" do
        within "p.alert" do
          page.should have_content("You do not have access to that page.")
        end
      end
    end
  end
end
