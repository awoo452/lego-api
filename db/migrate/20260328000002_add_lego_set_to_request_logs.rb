class AddLegoSetToRequestLogs < ActiveRecord::Migration[8.1]
  def change
    add_reference :request_logs, :lego_set, foreign_key: true
    add_index :request_logs, [:lego_set_id, :created_at]
  end
end
