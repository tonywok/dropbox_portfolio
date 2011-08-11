require 'ostruct'
class Admin::DropboxesController < ApplicationController

  before_filter :authenticate_admin! do
    dropbox_handshake
  end

  def new
  end

  def create
  end

  def dropbox_handshake
    if params[:oauth_token]
      dropbox_session = Dropbox::Session.deserialize(session[:dropbox_session])
      dropbox_session.authorize
      session[:dropbox_session] = dropbox_session.serialize
      redirect_to root_path
    else
      dropbox_session = Dropbox::Session.new(DROPBOX_KEY, DROPBOX_SECRET)
      session[:dropbox_session] = dropbox_session.serialize
      redirect_to dropbox_session.authorize_url(:oauth_callback => authorize_admin_dropboxes_url)
    end
  end
end
