class AddLegoSetToRequestLogs < ActiveRecord::Migration[8.1]
  def change
    return unless table_exists?(:lego_api_request_logs)

    ensure_lego_sets_table

    unless column_exists?(:lego_api_request_logs, :lego_set_id)
      add_column :lego_api_request_logs, :lego_set_id, :bigint
    end

    add_index :lego_api_request_logs, :lego_set_id unless index_exists?(:lego_api_request_logs, :lego_set_id)
    add_index :lego_api_request_logs, [ :lego_set_id, :created_at ] unless index_exists?(:lego_api_request_logs, [ :lego_set_id, :created_at ])
    unless foreign_key_exists?(:lego_api_request_logs, :lego_api_lego_sets, column: :lego_set_id)
      add_foreign_key :lego_api_request_logs, :lego_api_lego_sets, column: :lego_set_id
    end
  end

  private

  def ensure_lego_sets_table
    return if table_exists?(:lego_api_lego_sets)

    create_table :lego_api_lego_sets do |t|
      t.string :name
      t.string :external_id
      t.string :theme
      t.integer :num_parts
      t.string :image_url
      t.jsonb :raw_data

      t.timestamps
    end

    add_index :lego_api_lego_sets, :external_id, unique: true
  end
end
