require 'spec_helper'

describe Admin do
  describe "#linked_dropbox?" do
    context "admin has authenticated dropbox" do
      let(:admin) { Factory(:admin, :dropbox_oauth_token => 'Ds31dxZd12kL') }

      it "returns true" do
        admin.linked_dropbox?.should be_true
      end
    end

    context "admin has not yet authenticated dropbox" do
      let(:admin) { Factory(:admin) }

      it "returns false" do
        admin.linked_dropbox?.should be_false
      end
    end
  end
end
