require_relative "lib/smollama/version"

Gem::Specification.new do |spec|
  spec.name = "smollama"
  spec.version = Smollama::VERSION
  spec.authors = ["makevoid"]
  spec.email = ["makevoid@example.com"]

  spec.summary = "A simple Ruby client for Ollama API"
  spec.description = "SmolLama is a lightweight Ruby client for interacting with the Ollama API. It provides a simple interface for chat completions, streaming responses, and model management."
  spec.homepage = "https://github.com/makevoid/smollama"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/makevoid/smollama"
  spec.metadata["changelog_uri"] = "https://github.com/makevoid/smollama/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir["{lib}/**/*", "*.md", "*.gemspec", "Rakefile"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "excon", "~> 0.100"
  spec.add_dependency "base64"
  spec.add_dependency "logger"

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end