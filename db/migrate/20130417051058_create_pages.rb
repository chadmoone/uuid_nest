class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages, id: false do |t|
      t.string :uuid
      t.text :content
      t.string :book_id

      t.timestamps
    end
    add_index :pages, :uuid, unique: true
    add_index :pages, :book_id
    add_index(:pages, [:uuid, :book_id], :unique => true)
  end
end
