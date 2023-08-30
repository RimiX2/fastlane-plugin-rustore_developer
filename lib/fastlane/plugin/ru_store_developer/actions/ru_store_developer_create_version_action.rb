require 'fastlane/action'
require_relative '../helper/ru_store_developer_helper'

module Fastlane
  module Actions
    module SharedValues
      RU_STORE_DEVELOPER_DRAFT_VERSION = :RU_STORE_DEVELOPER_DRAFT_VERSION
    end

    class RuStoreDeveloperCreateVersionAction < Action

      def self.run(params)
        version = Helper::RuStoreDeveloperHelper.createVersion(params[:token], params[:package], nil )
        Actions.lane_context[SharedValues::RU_STORE_DEVELOPER_DRAFT_VERSION] = version.to_s
      end

      def self.description
        "RUSTORE deployment helper"
      end

      def self.authors
        ["Rim Ganiev"]
      end

      def self.return_value
        return version.to_s
      end

      def self.details
        # Optional:
        ""
      end

      def self.available_options
        [
            FastlaneCore::ConfigItem.new(key: :package,
                                         env_name: "RU_STORE_PACKAGE_NAME",
                                         description: "Android app package name (FQDN)",
                                         optional: false,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :token,
                                         description: "Access token",
                                         optional: false,
                                         sensitive: true,
                                         default_value: Actions.lane_context[SharedValues::RU_STORE_DEVELOPER_ACCESS_TOKEN],
                                         verify_block: proc do |value|
                                           UI.user_error!("No access token given, pass using `token: 'token_value'`") unless value && !value.empty?
                                         end,
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
