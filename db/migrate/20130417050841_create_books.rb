class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books, id: false do |t|
      t.string :uuid
      t.string :title

      t.timestamps
    end
    
  end
end
