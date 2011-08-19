class PagesController < ApplicationController
  layout 'frontend'

  def index
    @sections = Section.includes(:dropbox_files).all
  end
end
