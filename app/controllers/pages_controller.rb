class PagesController < ApplicationController
  def index
    @sections = Section.includes(:dropbox_files).all
  end
end
