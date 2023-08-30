require 'fastlane/action'
require_relative '../helper/ru_store_developer_helper'

module Fastlane
  module Actions
    class RuStoreDeveloperStatusAction < Action

      def self.run(params)
        if params[:version].nil?
          massive = Helper::RuStoreDeveloperHelper.getStatusAll(params[:token], params[:package])
          # puts(massive)
          exclude_cols = ['paid', 'priceValue', 'whatsNew', 'partialValue', 'sendDateForModer', 'publishDateTime',]
          col_labels = {versionId: "ID",
                        appName: "Title",
                        appType: "appType",
                        versionName: "vName",
                        versionCode: "vCode",
                        versionStatus: "Status",
                        publishType: 'publishType',
                        publishDateTime: 'Published',
                        sendDateForModer: 'Commited',
                        partialValue: 'Part',
                        whatsNew: 'whatsNew',
                        priceValue: 'Price',
                        paid: 'paid',
          }
          @columns = col_labels.each_with_object({}) { |(col, label), h|
            h[col] = {label: label,
                      width: [[(massive.map { |g| g[col.to_s].to_s.size }.max), 30].min, label.size].max}
          }

          # header top line
          puts "+-#{@columns.map { |_, g| '-' * g[:width] }.join('-+-')}-+"
          # header line
          puts "| #{@columns.map { |_, g| g[:label].to_s.ljust(g[:width]) }.join(' | ')} |"
          # # header bottom line
          puts "+-#{@columns.map { |_, g| '-' * g[:width] }.join('-+-')}-+"

          # row line
          massive.each do |row|
            str = row.keys.map { |k|
              a = row[k]
              if a.to_s.size > 30 then
                a = a.to_s[0..26] + "..."
              end
              a.to_s.ljust(@columns[k.to_sym][:width])
            }.join(' | ')
            puts "| #{str} |"
          end
          # bottom line
          puts "+-#{@columns.map { |_, g| '-' * g[:width] }.join('-+-')}-+"
        else
          info = Helper::RuStoreDeveloperHelper.getStatus(params[:token], params[:package], params[:version])
          puts(info)
        end

      end

      def self.description
        "RUSTORE deployment helper"
      end

      def self.authors
        ["Rim Ganiev"]
      end

      def self.return_value
        ""
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
            FastlaneCore::ConfigItem.new(key: :version,
                                         description: "Version ID",
                                         optional: true,
                                         type: String,
                                         default_value: Actions.lane_context[SharedValues::RU_STORE_DEVELOPER_DRAFT_VERSION]),
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
