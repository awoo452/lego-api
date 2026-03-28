# app/controllers/api/lego/sets_controller.rb
module Api
  module Lego
    class SetsController < ApplicationController
      def random
        result = ExternalApi::LegoService.random_set
        normalized = result["normalized"] || {}
        raw = result["raw"]
        metadata = result["metadata"] || {}

        lego_set_record = nil
        persist = params.fetch(:persist, "true").to_s.downcase != "false"
        if persist && normalized["external_id"].present?
          lego_set_record = LegoSet.find_or_initialize_by(external_id: normalized["external_id"])
          lego_set_record.assign_attributes(
            name: normalized["name"],
            theme: normalized["theme"],
            num_parts: normalized["num_parts"],
            image_url: normalized["image_url"],
            raw_data: raw
          )
          lego_set_record.save
          set_request_log_lego_set_id(lego_set_record.id) if lego_set_record.persisted?
        end

        append_request_log_metadata(
          lego: {
            "page" => metadata["page"],
            "page_size" => metadata["page_size"],
            "total_count" => metadata["total_count"],
            "external_id" => normalized["external_id"],
            "name" => normalized["name"],
            "theme" => normalized["theme"],
            "num_parts" => normalized["num_parts"],
            "upstream_status" => metadata["upstream_status"]
          },
          persist_param: params[:persist],
          lego_set_id: lego_set_record&.id
        )

        render json: {
          name: normalized["name"],
          external_id: normalized["external_id"],
          theme: normalized["theme"],
          num_parts: normalized["num_parts"],
          image_url: normalized["image_url"],
          raw: raw
        }
      end
    end
  end
end
