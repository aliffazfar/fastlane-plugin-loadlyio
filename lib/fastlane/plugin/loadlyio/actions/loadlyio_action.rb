require 'fastlane/action'
require_relative '../helper/loadlyio_helper'

module Fastlane
  module Actions
    class LoadlyioAction < Action
      def self.run(params)
        UI.message("The loadlyio plugin is working!")
      end

      def self.description
        "Loadly.io is the ultimate platform for app beta testing and distribution, offering unlimited app uploads and downloads, enhanced security, detailed analytics, and seamless integration. Alternative to TestFlight and Diawi"
      end

      def self.authors
        ["aliffazfar"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        ""
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "LOADLYIO_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
