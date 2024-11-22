# Fastlane plugin upload_to_loadly

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-loadlyio)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-upload_to_loadly`, add it to your project by running:

```bash
fastlane add_plugin upload_to_loadly
```

## About upload_to_loadly

Loadly.io is the ultimate platform for app beta testing and distribution, offering unlimited app uploads and downloads, enhanced security, detailed analytics, and seamless integration. Alternative to TestFlight and Diawi

This plugin can upload .ipa and .apk file to Loadly.

## Available options

| Key                   | Required   | Type     | Description                                                                                                |
| --------------------- | ---------- | -------- | ---------------------------------------------------------------------------------------------------------- |
| **api_key**           | **`true`** | `String` | [Loadly API Key](https://loadly.io/doc/view/api)                                                           |
| **file**              | `true`     | `String` | Path to .ipa or .apk file.<br>**Default**: `IPA_OUTPUT_PATH` or `GRADLE_APK_OUTPUT_PATH` based on platform |
| **build_password**    | `false`    | `String` | Set the App installation password. If the password is empty, public installation is used by default        |
| **build_description** | `false`    | `String` | Additional information to your users on this build: the comment will be displayed on the installation page |
| **callback_url**      | `false`    | `String` | The URL loadly should call with the result                                                                 |
| **timeout**           | `false`    | `Int`    | Timeout for uploading file to Loadly.<br>**Default**: 600<br>**Range**: (60, 1800)                         |

## Result link

If file upload successfully, you can access result link by:

`lane_context[SharedValues::UPLOADED_FILE_LINK_TO_LOADLY]`
`lane_context[SharedValues::QR_CODE_URL_TO_LOADLY]`
`lane_context[SharedValues::SHORTCUT_URL_TO_LOADLY]`

## Example

Minimal plugin configuration is:

```ruby
upload_to_loadly(
    api_key: "your_api_key",
    file: "your_app_file_path",
)
```

Advanced usage with all available options

```ruby
upload_to_loadly(
    api_key: ENV["LOADLY_API_KEY"],
    file: "./build/YourApp.ipa",
    build_password: "optional_password",
    build_description: "New version with feature X and Y",
    callback_url: "https://your-server.com/callback",
    timeout: 900 # Custom timeout in seconds (60-1800)
)
```

For more options see [**Available options**](#available-options) section.

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
