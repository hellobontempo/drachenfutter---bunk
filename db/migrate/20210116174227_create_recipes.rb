class CreateRecipes < ActiveRecord::Migration[6.1]
  def change
    create_table :recipes do |t|
      t.string :title
      t.text :instructions
      t.string :source

      t.timestamps
    end
  end
end