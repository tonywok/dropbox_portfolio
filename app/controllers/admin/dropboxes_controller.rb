require 'ostruct'

class Admin::DropboxesController < ApplicationController

  def new
  end

  def index
  end

  def create
    begin
      dropbox_session = Dropbox::Session.deserialize(session[:dropbox_session])
      @db_sync = DropboxSync.new(dropbox_session, params[:folder_name])

      respond_to do |format|
        format.json { render :json => @db_sync.meta }
      end

    rescue Dropbox::FileNotFoundError => e
      flash[:alert] = "Dropbox folder not found"
      render new_admin_dropbox_path
    end
  end

  def authorize
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
