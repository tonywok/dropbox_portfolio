class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :title
      t.string :section, :default => 'misc'
      t.text :description
      t.string :filename_identifier

      t.timestamps
    end
  end
end
