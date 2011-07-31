require 'ostruct'
class Admin::DropboxesController < ApplicationController
  before_filter :authenticate_admin!

  def new; end

  def create
    directory = get_dropbox_session.list(params[:folder_name], :mode => :dropbox)
    @imgs = directory.map { |i| i.path }
    render 'new'
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

  def get_dropbox_session
    @dropbox_session = Dropbox::Session.deserialize(session[:dropbox_session])
  end
end
