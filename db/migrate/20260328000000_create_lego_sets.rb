class CreateLegoSets < ActiveRecord::Migration[8.1]
  def change
    create_table :lego_sets do |t|
      t.string :name
      t.string :external_id
      t.string :theme
      t.integer :num_parts
      t.string :image_url
      t.jsonb :raw_data

      t.timestamps
    end

    add_index :lego_sets, :external_id, unique: true
  end
end
