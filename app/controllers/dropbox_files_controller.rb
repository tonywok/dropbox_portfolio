class DropboxFilesController < ApplicationController
  def index
    @dropbox_files = DropboxFile.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @dropbox_files }
    end
  end

  def show
    @dropbox_file = DropboxFile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @dropbox_file }
    end
  end
end
