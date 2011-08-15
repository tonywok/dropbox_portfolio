class ApplicationController < ActionController::Base
  protect_from_forgery

  def after_sign_in_path_for(admin)
    admin_items_path
  end
end
