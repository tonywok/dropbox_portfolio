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

      before do
        fill_in "admin_email", :with => admin.email
        fill_in "admin_password", :with => admin.password
        click_button "Sign in"
      end

      it "signs in the admin" do
        within "p.notice" do
          page.should have_content("Signed in successfully.")
        end
      end

      it "takes me to admin dashboard page" do
        page.current_path.should == admin_items_path
      end
    end

    context "invalid admin account" do
      before do
        fill_in "admin_email", :with => "jerk@face.com"
        fill_in "admin_password", :with => "balls"
        click_button "Sign in"
      end

      it 'redirects back to admins/sign_in' do
        page.current_path.should == new_admin_session_path
      end

      it "does not sign in the admin" do
        within "p.alert" do
          page.should have_content("Invalid email or password.")
        end
      end
    end
  end
end
