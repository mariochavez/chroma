# frozen_string_literal: true

require_relative "lib/chroma/version"

Gem::Specification.new do |spec|
  spec.name = "chroma-db"
  spec.version = Chroma::VERSION
  spec.authors = ["Mario Alberto Chávez"]
  spec.email = ["mario.chavez@gmail.com"]

  spec.summary = "Ruby client for Chroma DB."
  spec.description = "Chroma is the open-source embedding database. Chroma makes it easy to build LLM apps by making knowledge, facts, and skills pluggable for LLMs."
  spec.homepage = "https://mariochavez.io"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.4"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mariochavez/chroma"
  spec.metadata["changelog_uri"] = "https://github.com/mariochavez/chroma/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ notebook/ .git .circleci appveyor .standard.yml .rubocop.yml .solargraph.yml])
    end + Dir.glob("lib/.rbnext/**/*")
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "dry-monads", "~> 1.6"
  spec.add_dependency "zeitwerk", "~> 2.6.0"

  if ENV["RELEASING_GEM"].nil? && File.directory?(File.join(__dir__, ".git"))
    spec.add_runtime_dependency "ruby-next", "~> 1.0", ">= 1.0.3"
  else
    spec.add_dependency "ruby-next-core", "~> 1.0", ">= 1.0.3"
  end

  spec.add_development_dependency "ruby-next", "~> 1.0", ">= 1.0.3"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
