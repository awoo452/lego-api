class RequestLog < ApplicationRecord
  belongs_to :lego_set, optional: true
end
