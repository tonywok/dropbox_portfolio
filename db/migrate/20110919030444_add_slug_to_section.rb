class AddSlugToSection < ActiveRecord::Migration
  def self.up
    add_column :sections, :slug, :string
    add_index :sections, :slug, :unique => true
    add_column :dropbox_files, :slug, :string
    add_index :dropbox_files, :slug, :unique => true
  end

  def self.down
    remove_index :dropbox_files, :column => :slug
    remove_column :dropbox_files, :slug
    remove_index :sections, :column => :slug
    remove_column :sections, :slug
  end
end
