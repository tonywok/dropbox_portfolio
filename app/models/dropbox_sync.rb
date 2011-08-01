class DropboxSync
  attr_accessor :session, :section, :path, :meta, :parsed_meta

  def initialize(session, section)
    @session     = session
    @section     = section
    @meta        = session.ls(section)
    @parsed_meta = parse
  end

  def sync
    prune
    # refresh_existing
    # download_new
  end

  def prune
    prune_items
    prune_dropbox_files
  end

  def parse
    items = meta.inject({}) do |collection, element|
      item = parse_item(element.path)
      collection[item] ||= []
      collection[item] << element.path
      collection
    end
  end

  def prune_items
    Item.where("section = ? AND filename_identifier NOT IN (?)", section, parsed_meta.keys).destroy_all
  end

  def prune_dropbox_files
    DropboxFile.where("path IN (?)", parsed_meta.values.flatten).destroy_all
  end

  def parse_item(filename)
    filename.sub(%r(.*/), '').split('_').first.to_sym
  end
end
