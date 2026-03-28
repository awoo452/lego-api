# app/services/external_api/lego_service.rb
module ExternalApi
  class LegoService
    include HTTParty
    base_uri "https://rebrickable.com/api/v3/lego"
    default_timeout 5

    DEFAULT_PAGE_SIZE = 100
    DEFAULT_THEME_PAGE_SIZE = 1000
    THEME_CACHE_TTL = 60 * 60

    def self.random_set(theme: nil)
      theme_candidates = theme.present? ? resolve_theme_candidates(theme) : [ nil ]
      if theme.present? && theme_candidates.empty?
        return {
          "raw" => {},
          "normalized" => {},
          "metadata" => {
            "error" => "unknown_theme",
            "theme" => theme
          }
        }
      end

      page_size = DEFAULT_PAGE_SIZE
      selected = nil
      list_response = nil
      total_count = 0
      theme_id = nil
      page_used = nil

      theme_candidates.each do |candidate_id|
        count_response = get(
          "/sets/",
          headers: auth_headers,
          query: build_list_query(page: 1, page_size: 1, theme_id: candidate_id)
        )
        count_payload = count_response.parsed_response
        next unless count_payload.is_a?(Hash)

        total_count = count_payload["count"].to_i
        total_pages = total_count.positive? ? (total_count.to_f / page_size).ceil : 1
        page = rand(1..[ total_pages, 1000 ].min)

        list_response = get(
          "/sets/",
          headers: auth_headers,
          query: build_list_query(page: page, page_size: page_size, theme_id: candidate_id)
        )
        list_payload = list_response.parsed_response
        selected = pick_random_set(list_payload)
        if selected
          theme_id = candidate_id
          page_used = page
          break
        end
      end

      return fallback_empty(list_response&.code) unless selected

      detail_result = fetch_set_details(selected)
      detail_payload = detail_result ? detail_result["payload"] : nil
      detail_status = detail_result ? detail_result["status"] : nil

      {
        "raw" => detail_payload || selected,
        "normalized" => normalize_set(detail_payload || selected),
        "metadata" => {
          "page" => page_used,
          "page_size" => page_size,
          "total_count" => total_count,
          "list_status" => list_response&.code,
          "detail_status" => detail_status,
          "upstream_status" => detail_status || list_response&.code,
          "theme" => theme,
          "theme_id" => theme_id
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

    def self.build_list_query(page:, page_size:, theme_id:)
      query = { page: page, page_size: page_size }
      query[:theme_id] = theme_id if theme_id.present?
      query
    end
    private_class_method :build_list_query

    def self.resolve_theme_candidates(theme_key)
      normalized_key = normalize_theme_key(theme_key)
      return [] if normalized_key.empty?

      themes = fetch_themes
      return [] if themes.empty?

      matches = themes.select do |theme|
        normalize_theme_key(theme_name(theme)).include?(normalized_key)
      end

      matches.sort_by do |theme|
        name = normalize_theme_key(theme_name(theme))
        [
          name == normalized_key ? 0 : 1,
          name.start_with?(normalized_key) ? 0 : 1,
          theme["parent_id"].nil? ? 0 : 1,
          name.length
        ]
      end.map { |theme| extract_theme_id(theme) }.compact.uniq
    end
    private_class_method :resolve_theme_candidates

    def self.fetch_themes
      now = Time.now.to_i
      if defined?(@themes_cache) && @themes_cache && (now - @themes_cache[:fetched_at] < THEME_CACHE_TTL)
        return @themes_cache[:themes]
      end

      themes = []
      next_url = "/themes/"
      loop do
        response = get(next_url, headers: auth_headers, query: { page_size: DEFAULT_THEME_PAGE_SIZE })
        payload = response.parsed_response
        break unless payload.is_a?(Hash)

        results = payload["results"]
        themes.concat(results) if results.is_a?(Array)
        next_url = payload["next"]
        break if next_url.nil? || next_url.to_s.empty?
      end

      @themes_cache = { fetched_at: now, themes: themes }
      themes
    rescue StandardError
      []
    end
    private_class_method :fetch_themes

    def self.normalize_theme_key(value)
      value.to_s.downcase.gsub(/[^a-z0-9]+/, " ").strip
    end
    private_class_method :normalize_theme_key

    def self.theme_name(theme)
      theme["name"] || theme["theme_name"] || theme["title"] || theme["descr"]
    end
    private_class_method :theme_name

    def self.extract_theme_id(theme)
      return nil unless theme.is_a?(Hash)

      theme["id"] || theme["theme_id"]
    end
    private_class_method :extract_theme_id
  end
end
