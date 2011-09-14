class DropboxFilesController < ApplicationController
  layout 'frontend'

  def index
    @dropbox_files = DropboxFile.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @dropbox_files }
    end
  end

  def show
    @dropbox_file = DropboxFile.find(params[:id])

    if request.headers['X-PJAX']
      render :layout => false
    # else
    #   respond_to do |format|
    #     format.html
    #   end
    end
  end
end
