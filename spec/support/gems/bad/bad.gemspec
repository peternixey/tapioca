# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "bad"
  spec.version       = "0.5.0"
  spec.authors       = ["Test User"]
  spec.email         = ["test@example.com"]

  spec.summary       = "Bad - Test Gem"
  spec.homepage      = "https://example.com/should_error"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "no"

  spec.require_paths = ["lib"]

  spec.files         = Dir.glob("lib/**/*.rb")
end
