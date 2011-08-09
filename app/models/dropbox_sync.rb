class DropboxSync
  attr_accessor :session, :section, :path, :meta, :parsed_meta

  def initialize(session, section)
    @session     = session
    @section     = section
    @meta        = session.ls(section)
    @parsed_meta = parse
  end

  def parse
    meta.inject(HashWithIndifferentAccess.new) do |files_by_item, file|
      item = parse_item(file.path)
      files_by_item[item] ||= []
      files_by_item[item] << { :path     => file.path,
                               :revision => file.revision }
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
    Item.where("section = ? AND identifier NOT IN (?)", section, parsed_meta.keys).destroy_all
  end

  def prune_dropbox_files
    DropboxFile.includes(:item).where("items.section = ? AND path NOT IN (?)", section, meta_paths).destroy_all
  end

  def refresh
    revised_files    = DropboxFile.includes(:item).where("items.section = ? and revision NOT IN (?)", section, meta_revisions)
    up_to_date_files = DropboxFile.includes(:item).where("items.section = ? and revision IN (?)", section, meta_revisions)

    up_to_date_files.each do |file|
      delete_meta_file(file)
    end

    revised_files.each do |file|
      delete_meta_file(file)
      file.replace(session)
    end
  end

  def download_new
    parsed_meta.each_pair do |item_identifier, files|
      item = Item.find_or_create_by_identifier(:identifier => item_identifier,
                                               :section    => section)
      files.each do |file|
        db_file = item.dropbox_files.new(:path => file[:path], :revision => file[:revision])
        db_file.download(session)
      end
    end
  end

  def parse_item(filename)
    filename.match(%r(.*/([^_.]*))).captures.first.to_sym
  end

  private

  def meta_paths
    parsed_meta.values.flatten.map { |hash| hash[:path] }
  end

  def meta_revisions
    parsed_meta.values.flatten.map { |hash| hash[:revision] }
  end

  def delete_meta_file(file)
    parsed_meta[file.item.identifier].delete_if do |file_hash|
      (file_hash[:path] == file.path) && (file_hash[:revision] == file.revision)
    end
  end
end
