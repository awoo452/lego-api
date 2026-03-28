class RequestLog < ApplicationRecord
  self.table_name = "lego_api_request_logs"

  belongs_to :lego_set, optional: true
end
