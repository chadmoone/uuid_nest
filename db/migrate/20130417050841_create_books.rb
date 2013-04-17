class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books, id: false do |t|
      t.string :uuid
      t.string :title

      t.timestamps
    end
    add_index :books, :uuid, unique: true
  end
end
