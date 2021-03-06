module PagesHelper
  def portfolio_image_tag(dropbox_file)
    image_tag(url_for(dropbox_file.attachment.to_s))
  end

  def portfolio_show_path(dropbox_file)
    url_for("#{root_url}portfolio/#{dropbox_file.section.friendly_id}/#{dropbox_file.id}")
  end
end
