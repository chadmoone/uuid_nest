class CreateDecks < ActiveRecord::Migration
  def change
    create_table :decks, primary_key: :uuid do |t|
      t.string :title

      t.timestamps
    end
  end
end
