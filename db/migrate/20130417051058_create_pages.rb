class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages, id: false do |t|
      t.string :uuid
      t.text :content
      t.string :book_id

      t.timestamps
    end
    
  end
end
