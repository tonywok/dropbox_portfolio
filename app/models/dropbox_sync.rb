require 'json'

class DropboxSync
  attr_accessor :session, :section, :meta

  def initialize(session, section)
    @session = session
    @section = Section.find_or_create_by_name(:name => section['name'], :description => section['description'])
    @meta    = JSON.parse(section['dropbox_files'])
  end

  def run
    prune
    refresh
    download_new
  end

  def prune
    DropboxFile.includes(:section).
                where(:sections => {:name => section.name }).
                where('"meta_path" NOT IN (?)', meta_filepaths).
                destroy_all
  end

  def refresh
    revised_files = DropboxFile.includes(:section).
                                where(:sections => { :name => section.name }).
                                where('"revision" NOT IN (?)', meta_revisions)

    revised_files.each do |file|
      file.replace(session)
    end
  end

  def download_new
    local_filepaths = section.dropbox_files.map(&:meta_path)

    new_files = meta.reject do |dropbox_file|
      local_filepaths.include? dropbox_file["path"]
    end

    new_files.each do |file|
      dropbox_file = section.dropbox_files.new(:meta_path => file["path"], :revision => file["revision"])
      dropbox_file.download(session)
      dropbox_file.save
    end
  end

  private

  def meta_filepaths
    meta.map { |file| file["path"] }
  end

  def meta_revisions
    meta.map { |file| file["revision"].to_s }
  end
end
