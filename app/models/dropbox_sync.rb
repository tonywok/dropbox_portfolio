require 'json'

class DropboxSync
  attr_accessor :session, :section, :remote_dropbox_files

  def initialize(session, params)
    @session              = session
    @remote_dropbox_files = params.delete(:dropbox_files)
    @section              = Section.find_or_initialize_by_name(params)
    @section.description  = params[:description]
  end

  def run
    begin
    if section.new_record?
      download(remote_dropbox_files)
    else
      prune
      download(new_remote_files)
    end

    rescue Exception => e
      Rails.logger.fatal(e.inspect)
    end
  end

  def prune
    DropboxFile.includes(:section).
                where(:sections => { :name => section.name }).
                where('"meta_path" NOT IN (?)', remote_dropbox_files.map {|f| f[:path]}).
                destroy_all
  end

  def new_remote_files
    @new_remote_files ||= remote_dropbox_files.reject do |file|
      remaining_lookup[file["path"]] == file["revision"].to_s
    end
  end

  def download(new_files)
    unless new_files.empty?
      section.dropbox_files = new_files.map do |file|
        dropbox_file = section.dropbox_files.new(:meta_path => file[:path], :revision => file[:revision].to_s)
        dropbox_file.download(session)
        dropbox_file
      end
    end

    section.save

  rescue Exception => e
    Rails.logger.fatal e.inspect
  end

  private

  def remaining_lookup
    @remaining_lookup ||= section.dropbox_files.inject({}) do |remaining, file|
      remaining[file.meta_path] = file.revision
      remaining
    end
  end
end
