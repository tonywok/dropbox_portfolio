class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  def after_sign_in_path_for(admin)
    items_path
  end
end
