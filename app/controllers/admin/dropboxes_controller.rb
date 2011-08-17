require 'ostruct'

class Admin::DropboxesController < ApplicationController
  before_filter :get_dropbox_session

  def new
  end

  def index
    @dropbox_items = @dropbox_session.ls(params[:dir] || '/', :mode => :dropbox)

    respond_to do |format|
      format.html
      format.json { render :json => @dropbox_items }
    end
  end

  def sync
    dropbox_sync = DropboxSync.new(@dropbox_session)

    respond_to do |format|
      format.json { render :json => dropbox_sync.run(params[:stuff]) }
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

  private

  def get_dropbox_session
    @dropbox_session = Dropbox::Session.deserialize(session[:dropbox_session])
  end
end
