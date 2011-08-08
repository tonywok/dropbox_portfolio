class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :title
      t.string :section, :default => 'misc'
      t.text :description
      t.string :key
      t.string :identifier

      t.timestamps
    end
  end
end
