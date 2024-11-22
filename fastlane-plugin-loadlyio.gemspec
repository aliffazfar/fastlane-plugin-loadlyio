lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/loadlyio/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-loadlyio'
  spec.version       = Fastlane::Loadlyio::VERSION
  spec.author        = 'aliffazfar'
  spec.email         = 'aliffazfar34@gmail.com'

  spec.summary       = 'Loadly.io is the ultimate platform for app beta testing and distribution, offering unlimited app uploads and downloads, enhanced security, detailed analytics, and seamless integration. Alternative to TestFlight and Diawi'
  # spec.homepage      = "https://github.com/<GITHUB_USERNAME>/fastlane-plugin-loadlyio"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.required_ruby_version = '>= 2.6'

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  # spec.add_dependency 'your-dependency', '~> 1.0.0'
end
