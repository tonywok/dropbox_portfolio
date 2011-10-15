require 'json'

class DropboxSync
  attr_accessor :session, :section, :remote_dropbox_files

  def initialize(session, data)
    @session              = session
    @section              = Section.find_or_initialize_by_name(:name => data['name'])
    @section.description  = data["description"]
    @remote_dropbox_files = JSON.parse(data["dropbox_files"])
  end

  def run
    if section.new_record?
      download(remote_dropbox_files)
    else
      prune
      download(new_remote_files)
    end
  end

  def prune
    DropboxFile.includes(:section).
                where(:sections => { :name => section.name }).
                where('"meta_path" NOT IN (?)', meta_filepaths).destroy_all
  end

  def new_remote_files
    remaining_lookup = section.dropbox_files.inject({}) do |remaining, file|
      remaining[file.meta_path] = file.revision
      remaining
    end

    remote_dropbox_files.reject { |file| remaining_lookup[file["path"]] == file["revision"] }
  end

  def download(new_files)
    new_dropbox_files = new_files.map do |file|
      dropbox_file = section.dropbox_files.new(:meta_path => file["path"], :revision => file["revision"])
      dropbox_file.download(session)
      dropbox_file
    end

    section.update_attributes(:description => section.description,
                              :dropbox_files => new_dropbox_files)
  end

  private

  def meta_filepaths
    remote_dropbox_files.map { |file| file["path"] }
  end

end
