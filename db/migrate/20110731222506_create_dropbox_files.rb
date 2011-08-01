class CreateDropboxFiles < ActiveRecord::Migration
  def change
    create_table :dropbox_files do |t|
      t.integer :item_id
      t.string :path
      t.string :revision
      t.string :attachment

      t.timestamps
    end
  end
end
