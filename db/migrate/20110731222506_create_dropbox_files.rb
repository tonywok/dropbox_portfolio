class CreateDropboxFiles < ActiveRecord::Migration
  def change
    create_table :dropbox_files do |t|
      t.integer :section_id
      t.string :meta_path
      t.string :revision
      t.string :attachment

      t.timestamps
    end
  end
end
