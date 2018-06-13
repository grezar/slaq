lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "slaq/version"

Gem::Specification.new do |spec|
  spec.name          = "slaq"
  spec.version       = Slaq::VERSION
  spec.authors       = ["grezar"]
  spec.email         = ["grezar.dev@gmail.com"]

  spec.summary       = %q{This is a quiz app integrated with slack.}
  spec.homepage      = "https://github.com/grezar/slaq"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
