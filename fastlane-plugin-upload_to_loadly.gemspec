lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/upload_to_loadly/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-upload_to_loadly'
  spec.version       = Fastlane::UploadToLoadly::VERSION
  spec.author        = 'aliffazfar'
  spec.email         = 'aliffazfar34@gmail.com'

  spec.summary       = 'Loadly.io is the ultimate platform for app beta testing and distribution, offering unlimited app uploads and downloads, enhanced security, detailed analytics, and seamless integration. Alternative to TestFlight and Diawi'
  spec.homepage      = "https://github.com/aliffazfar/fastlane-plugin-loadlyio"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  # spec.add_dependency 'your-dependency', '~> 1.0.0'

  spec.add_dependency 'rest-client', '>= 2.0.0'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'fastlane', '>= 1.93.0'
end
