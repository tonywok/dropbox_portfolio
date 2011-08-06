class DropboxSync
  attr_accessor :session, :section, :path, :meta, :parsed_meta

  def initialize(session, section)
    @session     = session
    @section     = section
    @meta        = session.ls(section)
    @parsed_meta = parse
  end

  def parse
    meta.inject({}) do |files_by_item, file|
      item = parse_item(file.path)
      files_by_item[item] ||= []
      files_by_item[item] << file.path
      files_by_item
    end
  end

  def sync
    prune
    refresh
    download_new
  end

  def prune
    prune_items
    prune_dropbox_files
  end

  def prune_items
    outdated_items = Item.where("section = ? AND filename_identifier NOT IN (?)", section, parsed_meta.keys)
    outdated_items.destroy_all
  end

  def prune_dropbox_files
    DropboxFile.where("path IN (?)", parsed_meta.values.flatten).destroy_all
  end

  def refresh
    meta_revisions   = @meta.collect(&:revision)
    revised_files    = DropboxFile.includes(:item).where("revision NOT IN (?)", meta_revisions)
    up_to_date_files = DropboxFile.includes(:item).where("revision IN (?)", meta_revisions)

    up_to_date_files.each do |file|
      parsed_meta[file.item.filename_identifier.to_sym].delete(file.path)
    end

    revised_files.each do |file|
      parsed_meta[file.item.filename_identifier.to_sym].delete(file.path)
      file.replace(session)
    end
  end

  def download_new
  end

  def parse_item(filename)
    filename.match(%r(.*/([^_.]*))).captures.first.to_sym
  end

end
