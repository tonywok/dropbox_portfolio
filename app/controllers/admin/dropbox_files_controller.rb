class Admin::DropboxFilesController < ApplicationController
  def index
    @dropbox_files = DropboxFile.all
  end

  def edit
    @dropbox_file = DropboxFile.find(params[:id])
  end

  def update
    @dropbox_file = DropboxFile.find(params[:id])

    respond_to do |format|
      if @dropbox_file.update_attributes(params[:item])
        format.html { redirect_to @dropbox_file, notice: 'DropboxFile was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @dropbox_file.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @dropbox_file = DropboxFile.find(params[:id])
    @dropbox_file.destroy

    respond_to do |format|
      format.html { redirect_to files_url }
      format.json { head :ok }
    end
  end
end
