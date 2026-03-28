class LegoSet < ApplicationRecord
  self.table_name = "lego_api_lego_sets"

  has_many :request_logs, dependent: :nullify
end
