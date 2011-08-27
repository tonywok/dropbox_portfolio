module Admin::DropboxesHelper

  def section_names
    Section.all.map(&:name).to_json
  end

end
