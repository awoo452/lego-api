# app/services/external_api/lego_service.rb
module ExternalApi
  class LegoService
    include HTTParty
    base_uri "https://rebrickable.com/api/v3/lego"
    default_timeout 5

    DEFAULT_PAGE_SIZE = 100

    def self.random_set
      count_response = get("/sets/", headers: auth_headers, query: { page: 1, page_size: 1 })
      count_payload = count_response.parsed_response
      total_count = count_payload.is_a?(Hash) ? count_payload["count"].to_i : 0

      page_size = DEFAULT_PAGE_SIZE
      total_pages = total_count.positive? ? (total_count.to_f / page_size).ceil : 1
      page = rand(1..[total_pages, 1000].min)

      list_response = get(
        "/sets/",
        headers: auth_headers,
        query: { page: page, page_size: page_size }
      )
      list_payload = list_response.parsed_response
      selected = pick_random_set(list_payload)
      return fallback_empty(list_response.code) unless selected

      detail_result = fetch_set_details(selected)
      detail_payload = detail_result ? detail_result["payload"] : nil
      detail_status = detail_result ? detail_result["status"] : nil

      {
        "raw" => detail_payload || selected,
        "normalized" => normalize_set(detail_payload || selected),
        "metadata" => {
          "page" => page,
          "page_size" => page_size,
          "total_count" => total_count,
          "list_status" => list_response.code,
          "detail_status" => detail_status,
          "upstream_status" => detail_status || list_response.code
        }
      }
    end

    def self.pick_random_set(payload)
      return nil unless payload.is_a?(Hash)

      results = payload["results"]
      return nil unless results.is_a?(Array) && results.any?

      results.sample
    end
    private_class_method :pick_random_set

    def self.fetch_set_details(selected)
      return nil unless selected.is_a?(Hash)

      set_num = selected["set_num"]
      return nil if set_num.to_s.strip.empty?

      detail_response = get("/sets/#{set_num}/", headers: auth_headers)
      detail_payload = detail_response.parsed_response
      return nil unless detail_payload.is_a?(Hash)

      {
        "payload" => detail_payload,
        "status" => detail_response.code
      }
    end
    private_class_method :fetch_set_details

    def self.normalize_set(payload)
      return {} unless payload.is_a?(Hash)

      {
        "name" => payload["name"],
        "external_id" => payload["set_num"],
        "theme" => payload["theme_name"] || payload["theme"] || payload["theme_id"]&.to_s,
        "num_parts" => payload["num_parts"],
        "image_url" => payload["set_img_url"] || payload["image_url"] || payload["image"]
      }
    end
    private_class_method :normalize_set

    def self.fallback_empty(status)
      {
        "raw" => {},
        "normalized" => {},
        "metadata" => {
          "error" => "no_results",
          "upstream_status" => status
        }
      }
    end
    private_class_method :fallback_empty

    def self.auth_headers
      api_key = ENV["REBRICKABLE_API_KEY"]
      return {} if api_key.to_s.strip.empty?

      { "Authorization" => "key #{api_key}" }
    end
    private_class_method :auth_headers
  end
end
