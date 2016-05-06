# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bank_teller/version'

Gem::Specification.new do |spec|
  spec.name          = "bank_teller"
  spec.version       = BankTeller::VERSION
  spec.authors       = ["Jason Charnes"]
  spec.email         = ["jason@thecharnes.com"]

  spec.summary       = %q{A subscription billing interface modeled after Laravel Cashier}
  spec.description   = %q{A subscription billing interface modeled after Laravel Cashier}
  spec.homepage      = "http://www.github.com/jasoncharnes/bank_teller"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "app"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'activerecord'
  spec.add_runtime_dependency 'stripe'
end
