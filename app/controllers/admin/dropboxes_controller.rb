require 'ostruct'

class Admin::DropboxesController < ApplicationController
  layout 'backend'
  before_filter :authenticate, :except => [:authorize]

  def index
    @dropbox_items = @dropbox_session.ls(params[:dir] || '/')

    respond_to do |format|
      format.html
      format.json { render :json => @dropbox_items }
    end
  end

  def sync
    dropbox_sync = DropboxSync.new(@dropbox_session, params[:section])

    respond_to do |format|
      format.json { render :json => dropbox_sync.run }
    end
  end

  def authorize
    if params[:oauth_token]
      dropbox_session = Dropbox::Session.deserialize(session[:dropbox_session])
      dropbox_session.authorize
      session[:dropbox_session] = dropbox_session.serialize
      redirect_to admin_dropboxes_url
    else
      dropbox_session = Dropbox::Session.new(DROPBOX_KEY, DROPBOX_SECRET)
      session[:dropbox_session] = dropbox_session.serialize
      redirect_to dropbox_session.authorize_url(:oauth_callback => authorize_admin_dropboxes_url)
    end
  end

  private

  def authenticate
    return redirect_to(:action => 'authorize') unless session[:dropbox_session]
    @dropbox_session = Dropbox::Session.deserialize(session[:dropbox_session])
    @dropbox_session.mode = (Rails.env.test? ? :sandbox : :dropbox)
    return redirect_to(:action => 'authorize') unless @dropbox_session.authorized?
  end
end
