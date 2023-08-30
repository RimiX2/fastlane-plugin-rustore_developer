require 'fastlane_core/ui/ui'
require "base64"

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class RuStoreDeveloperHelper

      BASE_URL = 'https://public-api.rustore.ru'

      def self.getTimestamp()
        return DateTime.now.to_s()
        # return '2023-08-23T09:00:32.939+03:00'
      end

      def self.getSignatureEncoded(company_id, timestamp, key_path)
        private_key = OpenSSL::PKey.read(File.read(key_path))
        data = company_id + timestamp
        signature = private_key.sign("SHA512", data)
        encoded = Base64.strict_encode64(signature)
        return encoded
      end

      def self.getAccessToken(company_id, key_path)
        UI.important("Getting access token ...")
        timestamp = getTimestamp()
        sign = getSignatureEncoded(company_id, timestamp, key_path)
        uri = URI(BASE_URL + '/public/auth/')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path)
        req["Content-Type"] = "application/json"
        data = {'companyId': company_id, 'timestamp': timestamp, 'signature': sign}
        req.body = data.to_json
        res = http.request(req)
        result_json = JSON.parse(res.body)
        token = result_json['body']['jwe'] if result_json['code'] == 'OK'

        if token.nil?
          UI.error("Cannot retrieve access token, please check your credentials.\n#{result_json['message']}")
        else
          UI.success 'Got access token'
          # UI.message token
        end

        return token
      end

      def self.createVersion(token, package_name, publish_type = 'INSTANTLY', app_type = 'MAIN', whats_new)
        UI.important("Creating draft version of '#{package_name}' ...")
        uri = URI(BASE_URL + "/public/v1/application/#{package_name}/version")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path)
        req["Content-Type"] = "application/json"
        req["Public-Token"] = token
        data = {'publishType': publish_type, 'appType': app_type, 'whatsNew': whats_new}
        req.body = data.to_json
        # puts req.body
        res = http.request(req)
        # puts res.body
        result_json = JSON.parse(res.body)

        version = result_json['body'] if result_json['code'] == 'OK'
        if version.nil?
          UI.error("#{result_json['message']}")
        else
          UI.success "Created new version: #{version}"
        end

        return version
      end

      def self.deleteDraft(token, package_name, version_id)
        UI.important("Deleting draft version #{version_id} ...")
        uri = URI(BASE_URL + "/public/v1/application/#{package_name}/version/#{version_id}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Delete.new(uri.path)
        req["Public-Token"] = token
        res = http.request(req)
        result_json = JSON.parse(res.body)
        if result_json['code'] != 'OK'
          UI.error("#{result_json['message']}")
        else
          UI.success "Successfully deleted"
        end
      end

      def self.getStatus(token, package_name, version_id, page = 0, size = 10)
        # METHOD_URL = BASE_URL + "/public/v1/application/#{package_name}/version"
        if version_id.nil?
          UI.important("Getting status of  \'#{package_name}\' versions on page #{page} ...")
          uri = URI(BASE_URL + "/public/v1/application/#{package_name}/version?page=#{page}&size=#{size}")
        else
          UI.important("Getting status of \'#{package_name}\' version #{version_id} ...")
          uri = URI(BASE_URL + "/public/v1/application/#{package_name}/version?id=#{version_id}")
        end
        puts(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Get.new(uri.path)
        req["Public-Token"] = token
        req["Content-Type"] = "application/json"
        res = http.request(req)
        result_json = JSON.parse(res.body)
        if result_json['code'] == 'OK'
          content = result_json['body']['content']
          totalVersions = result_json['body']['totalElements']
          totalPages = result_json['body']['totalPages']
        end

        if content.nil?
          UI.error("#{result_json['message']}")
        else
          if version_id.nil?
            UI.success "Got #{totalVersions} versions in #{totalPages} pages"
          else
            UI.success "Got version info"
          end
        end

        return content
      end

      def self.getStatusAll(token, package_name, page = 0, size = 100)
        self.getStatus(token, package_name, nil, page, size)
      end

      def self.uploadAPK(token, package_name, version_id, apk_path, is_main = true, service_type = 'Unknown')
        UI.important("Uploading APK #{apk_path} ...")
        uri = URI(BASE_URL + "/public/v1/application/#{package_name}/version/#{version_id}/apk?isMainApk=#{is_main}&servicesType=#{service_type}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path)
        req["Public-Token"] = token
        req.set_content_type("multipart/form-data")
        req.set_form_data(params[['file', File.open(apk_path)]])
        # req.set_form([['file', File.open(file_path)]], 'multipart/form-data')
        res = http.request(req)
        result_json = JSON.parse(res.body)
        if result_json['code'] != 'OK'
          UI.error("#{result_json['message']}")
        else
          UI.success "APK uploaded"
        end
      end

      def self.commitVersion(token, package_name, version_id, priority_update = 0)
        UI.important("Committing version #{version_id} ...")
        uri = URI(BASE_URL + "/public/v1/application/#{package_name}/version/#{version_id}/commit?priorityUpdate=#{priority_update}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path)
        req["Public-Token"] = token
        puts req.body
        res = http.request(req)
        puts res.body
        result_json = JSON.parse(res.body)
        if result_json['code'] != 'OK'
          UI.error("#{result_json['message']}")
        else
          UI.success "Successfully committed"
        end
      end

      def self.publishVersion(token, package_name, version_id, priority_update = 0)
        UI.important("Publishing version #{version_id} ...")
        uri = URI(BASE_URL + "/public/v1/application/#{package_name}/version/#{version_id}/publish")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path)
        req["Public-Token"] = token
        puts req.body
        res = http.request(req)
        puts res.body
        result_json = JSON.parse(res.body)
        if result_json['code'] != 'OK'
          UI.error("#{result_json['message']}")
        else
          UI.success "Successfully published"
        end
      end
    end

  end
end
