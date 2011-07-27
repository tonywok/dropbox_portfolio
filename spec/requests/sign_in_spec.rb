require 'spec_helper'

describe "Sign in as admin" do
  describe "GET /admins/sign_in" do
    it "takes me to the admin sign in page" do
      get new_admin_session_path
      response.status.should be(200)
    end
  end

  describe "POST /admins/sign_in" do
    before { visit new_admin_session_path }
    context "valid admin account" do
      let(:admin) { Factory(:admin) }

      it "signs in the admin" do
        fill_in "admin_email", :with => admin.email
        fill_in "admin_password", :with => admin.password
        click_button "Sign in"
        within "p.notice" do
          page.should have_content("Signed in successfully.")
        end
      end
    end

    context "invalid admin account" do
      it "does not sign in the admin" do
        fill_in "admin_email", :with => "jerk@face.com"
        fill_in "admin_password", :with => "balls"
        click_button "Sign in"
        within "p.alert" do
          page.should have_content("Invalid email or password.")
        end
      end
    end
  end
end
