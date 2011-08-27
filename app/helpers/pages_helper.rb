module PagesHelper
  def portfolio_image_tag(dropbox_file)
    image_tag(url_for(dropbox_file.attachment.to_s))
  end

  def portfolio_show_path(dropbox_file)
    url_for("portfolio/#{dropbox_file.section.name}/#{dropbox_file.id}")
  end
end
