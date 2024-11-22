require 'fastlane/action'
require_relative '../helper/loadlyio_helper'

module Fastlane
  module Actions

      module SharedValues
          UPLOADED_FILE_LINK_TO_LOADLY = :UPLOADED_FILE_LINK_TO_LOADLY
          QR_CODE_URL_TO_LOADLY = :QR_CODE_URL_TO_LOADLY
          SHORTCUT_URL_TO_LOADLY = :SHORTCUT_URL_TO_LOADLY
      end

      class LoadlyAction < Action

          UPLOAD_URL = "https://api.loadly.io/apiv2/app/upload"
          LOADLY_FILE_LINK = "https://i.loadly.io"

          def self.run(options)
              Actions.verify_gem!('rest-client')
              require 'rest-client'
              require 'json'

              if options[:file].nil?
                  UI.important("File didn't come to LOADLY_plugin. Uploading is unavailable.")
                  return
              end

              if options[:api_key].nil?
                  UI.important("Loadly.io api_key is empty - uploading is unavailable.")
                  UI.important("Try to upload file by yourself. Path: #{options[:file]}")
                  return
              end

              upload_options = {
                  _api_key: options[:api_key],
                  buildPassword: options[:build_password],
                  buildUpdateDescription: options[:build_description],
                  file: File.new(options[:file], 'rb'),
              }

              timeout = options[:timeout]

              UI.success("Start uploading file to loadly. Please, be patient. This could take some time.")

              response = RestClient::Request.execute(
                  method: :post,
                  url: UPLOAD_URL,
                  timeout: timeout,
                  payload: upload_options
              )

              begin
                  response
              rescue RestClient::ExceptionWithResponse => error
                  UI.error("❌ Upload failed!")
                  UI.important("Failed to upload file to loadly, because of:")
                  UI.important(error)
                  UI.important("Try to upload file by yourself. Path: #{options[:file]}")
                  return
              end

              data = JSON.parse(response.body)['data']
              
              if data
                  download_url = "#{LOADLY_FILE_LINK}/#{data['buildKey']}"
                  qr_code_url = data['buildQRCodeURL']
                  shortcut_url = data['buildShortcutUrl']
                  
                  Actions.lane_context[SharedValues::UPLOADED_FILE_LINK_TO_LOADLY] = download_url
                  Actions.lane_context[SharedValues::QR_CODE_URL_TO_LOADLY] = qr_code_url
                  Actions.lane_context[SharedValues::SHORTCUT_URL_TO_LOADLY] = shortcut_url
                  
                  UI.success("✅ Upload completed successfully.")
                  UI.success("📱 Install URLs:")
                  UI.message("   • Download URL:  #{download_url}")
                  UI.message("   • Shortcut URL: #{shortcut_url}")
                  UI.message("   • QR Code URL:  #{qr_code_url}")

                  if !options[:callback_url].nil?
                      data['download_url'] = download_url
                      self.callback(options[:callback_url], data)
                  end
                  
                  return
              end
          end

          def self.callback(url, data)
              UI.success("Performing callback to #{url}")
              RestClient.post(url, data)
              UI.success("Callback sucessfully")
          end

          def self.default_file_path
              platform = Actions.lane_context[SharedValues::PLATFORM_NAME]
              ios_path = Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]
              android_path = Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH]
              return platform == :ios ? ios_path : android_path 
          end
          
          #####################################################
          # @!group Documentation
          #####################################################

          def self.available_options
              [
                  FastlaneCore::ConfigItem.new(key: :api_key,
                                          env_name: "LOADLY_API_KEY",
                                       description: "Loadly API Key",
                                          optional: false),
                  FastlaneCore::ConfigItem.new(key: :file,
                                          env_name: "LOADLY_FILE",
                                       description: "Path to .ipa or .apk file. Default - `IPA_OUTPUT_PATH` or `GRADLE_APK_OUTPUT_PATH` based on platform",
                                          optional: true,
                                     default_value: self.default_file_path),
                  FastlaneCore::ConfigItem.new(key: :build_password,
                                          env_name: "LOADLY_BUILD_PASSWORD",
                                       description: "Set the App installation password. If the password is empty, public installation is used by default",
                                          optional: true),
                  FastlaneCore::ConfigItem.new(key: :build_description,
                                          env_name: "LOADLY_BUILD_UPDATE_DESCRIPTION",
                                       description: "Additional information to your users on this build: the comment will be displayed on the installation page",
                                          optional: true),
                  FastlaneCore::ConfigItem.new(key: :callback_url,
                                          env_name: "LOADLY_CALLBACK_URL",
                                       description: "The URL loadly should call with the result",
                                          optional: true),
                  FastlaneCore::ConfigItem.new(key: :timeout,
                                          env_name: "LOADLY_TIMEOUT",
                                       description: "Timeout for uploading file to Loadly. Default: 600, range: (60, 1800)",
                                         is_string: false,
                                          optional: true,
                                     default_value: 600),
              ]
          end

          def self.output
              [
                  ['UPLOADED_FILE_LINK_TO_LOADLY', 'URL to uploaded .ipa or .apk file to loadly.']
              ]
          end

          def self.description
              "Upload .ipa/.apk file to loadly.io"
          end

          def self.authors
            ["aliffazfar"]
          end

          def self.details
              "This action upload .ipa/.apk file to https://loadly.io and return link to uploaded file."
          end

          def self.is_supported?(platform)
              [:ios, :android].include?(platform)
          end
      end
  end
end
