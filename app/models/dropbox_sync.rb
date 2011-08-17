class DropboxSync
  attr_accessor :session, :section, :meta

  def initialize(session, section_name)
    @session = session
    @section = Section.find_by_name(section_name)
  end

  def run(meta)
    @meta = meta
    prune
    refresh
    download_new
  end

  def prune
    DropboxFile.includes(:sections).
                where(:sections => {:name => section.name }).
                where("dropbox_files.attachment NOT IN (?)", meta_filenames).
                destroy_all
  end

  def refresh
    revised_files = DropboxFile.includes(:sections).
                                where(:sections => { :name => section.name }).
                                where("revision NOT IN (?)", meta_revisions)

    revised_files.each do |file|
      file.replace(session)
    end
  end

  def download_new
    local_filenames = section.dropbox_files.map(&:name)

    meta.each do |file|
      if local_filenames.include?(File.basename(file.path))
        dropbox_file = section.dropbox_files.new(:path => file.path,
                                                 :revision => file.revision)
        dropbox_file.download(session)
        dropbox_file.save
      end
    end
  end

  private

  def meta_filenames
    meta.map { |file| File.basename(file.path) }
  end

  def meta_revisions
    meta.map { |file| file.revision }
  end
end
