require 'fastlane/action'
require_relative '../helper/ru_store_developer_helper'

module Fastlane
  module Actions
    module SharedValues
      RU_STORE_DEVELOPER_ACCESS_TOKEN = :RU_STORE_DEVELOPER_ACCESS_TOKEN
    end
    class RuStoreDeveloperAuthAction < Action

      def self.run(params)
        token = Helper::RuStoreDeveloperHelper.getAccessToken(params[:id], params[:key_path])
        Actions.lane_context[SharedValues::RU_STORE_DEVELOPER_ACCESS_TOKEN] = token
        return token
      end

      def self.description
        "RUSTORE deployment helper"
      end

      def self.authors
        ["Rim Ganiev"]
      end

      def self.return_value
        "Access token"
      end

      def self.details
        # Optional:
        ""
      end

      def self.available_options
        [
            FastlaneCore::ConfigItem.new(key: :id,
                                         env_name: "RU_STORE_COMPANY_ID",
                                         description: "Company ID",
                                         optional: false,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :key_path,
                                         env_name: "RU_STORE_PRIVATE_KEY_PATH",
                                         description: "Path for the company's private key (PEM)",
                                         optional: false,
                                         type: String)
        ]
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
        true
      end
    end
  end
end
