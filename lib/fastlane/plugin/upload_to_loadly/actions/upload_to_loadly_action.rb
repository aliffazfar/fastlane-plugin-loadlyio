module Fastlane
  module Actions

    module SharedValues
      UPLOADED_FILE_LINK_TO_LOADLY = :UPLOADED_FILE_LINK_TO_LOADLY
      QR_CODE_URL_TO_LOADLY = :QR_CODE_URL_TO_LOADLY
      SHORTCUT_URL_TO_LOADLY = :SHORTCUT_URL_TO_LOADLY
    end

    class UploadToLoadlyAction < Action

      UPLOAD_URL = "https://api.loadly.io/apiv2/app/upload"
      LOADLY_FILE_LINK = "https://i.loadly.io"

      def self.run(options)
        Actions.verify_gem!('rest-client')
        require 'rest-client'
        require 'json'
        require 'thread'

        if options[:file].nil?
          UI.important("File didn't come to LOADLY_plugin. Uploading is unavailable.")
          return
        end

        if options[:api_key].nil?
          UI.important("Loadly.io api_key is empty - uploading is unavailable.")
          UI.important("Try to upload file by yourself. Path: #{options[:file]}")
          return
        end

        file_size = File.size(options[:file])
        file_name = File.basename(options[:file])

        upload_options = {
          _api_key: options[:api_key],
          buildPassword: options[:build_password],
          buildUpdateDescription: options[:build_description],
          file: File.new(options[:file], 'rb'),
        }

        timeout = options[:timeout]

        UI.message("📦 Preparing to upload #{file_name} (#{format_size(file_size)})")
        UI.message("⏳ Initializing upload to Loadly.io...")

        started_at = Time.now
        spinner_chars = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏']
        spinner_index = 0
        spinner_running = true

        # Start the spinner thread
        spinner_thread = Thread.new do
          while spinner_running
            spinner = spinner_chars[spinner_index % spinner_chars.length]
            elapsed = Time.now - started_at
            UI.message("#{spinner} Uploading... (#{format_time(elapsed)})")
            spinner_index += 1
            sleep(1)
          end
        end

        begin
          response = RestClient::Request.execute(
            method: :post,
            url: UPLOAD_URL,
            timeout: timeout,
            payload: upload_options
          )
          spinner_running = false
          spinner_thread.join # Wait for spinner to finish
          UI.message("\r ") # Clear spinner line

          data = JSON.parse(response.body)['data']

          if data
            download_url = "#{LOADLY_FILE_LINK}/#{data['buildKey']}"
            qr_code_url = data['buildQRCodeURL']
            shortcut_url = "#{LOADLY_FILE_LINK}/#{data['buildShortcutUrl']}"

            Actions.lane_context[SharedValues::UPLOADED_FILE_LINK_TO_LOADLY] = download_url
            Actions.lane_context[SharedValues::QR_CODE_URL_TO_LOADLY] = qr_code_url
            Actions.lane_context[SharedValues::SHORTCUT_URL_TO_LOADLY] = shortcut_url

            total_time = Time.now - started_at
            UI.success("✅ Upload completed successfully: #{file_name} (#{format_size(file_size)})")
            UI.success("📱 Install URLs:")
            UI.message("   • Download URL:  #{download_url}")
            UI.message("   • Shortcut URL: #{shortcut_url}")
            UI.message("   • QR Code URL:  #{qr_code_url}")

            if !options[:callback_url].nil?
              data['download_url'] = download_url
              self.callback(options[:callback_url], data)
            end

            return
          else
            UI.error("❌ Upload failed! No response data received.")
          end
        rescue RestClient::ExceptionWithResponse => error
          spinner_running = false
          spinner_thread.join
          UI.message("\r ") # Clear spinner line
          UI.error("❌ Upload failed!")
          UI.important("Failed to upload file to loadly, because of:")
          UI.important(error.message)
          UI.important("Try to upload file by yourself. Path: #{options[:file]}")
        end
      end

      def self.format_size(size_in_bytes)
        units = ['B', 'KB', 'MB', 'GB']
        unit_index = 0
        size = size_in_bytes.to_f

        while size > 1024 && unit_index < units.length - 1
          size /= 1024
          unit_index += 1
        end

        "%.2f %s" % [size, units[unit_index]]
      end

      def self.format_time(seconds)
        if seconds < 60
          "#{seconds.round}s"
        elsif seconds < 3600
          minutes = (seconds / 60).floor
          remaining_seconds = (seconds % 60).round
          "#{minutes}m #{remaining_seconds}s"
        else
          hours = (seconds / 3600).floor
          remaining_minutes = ((seconds % 3600) / 60).floor
          "#{hours}h #{remaining_minutes}m"
        end
      end

      def self.callback(url, data)
        UI.success("Performing callback to #{url}")
        RestClient.post(url, data)
        UI.success("Callback successfully")
      end

      def self.default_file_path
        platform = Actions.lane_context[SharedValues::PLATFORM_NAME]
        ios_path = Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]
        android_path = Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH]
        return platform == :ios ? ios_path : android_path
      end

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
