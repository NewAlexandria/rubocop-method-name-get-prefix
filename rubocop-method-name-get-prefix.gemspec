# frozen_string_literal: true

require_relative 'lib/rubocop-method-name-get-prefix/version'

Gem::Specification.new do |spec|
  spec.name          = 'rubocop-method-name-get-prefix'
  spec.version       = RuboCop::MethodNameGetPrefix::VERSION
  spec.authors       = ['NewAlexandria']
  spec.email         = ['nospam@newalexandria.org']

  spec.summary       = 'RuboCop cop to prevent non-idiomatic get_ prefix in method names'
  spec.description   = 'A RuboCop extension that flags methods with get_ prefix that take arguments, ' \
                        'suggesting more idiomatic Ruby naming conventions like *_for or find_* patterns.'
  spec.homepage      = 'https://github.com/NewAlexandria/rubocop-method-name-get-prefix'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    files = if system('git rev-parse --git-dir > /dev/null 2>&1')
              `git ls-files -z`.split("\x0")
            else
              Dir['**/*'].reject { |f| File.directory?(f) }
            end
    files.reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile export/])
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rubocop', '>= 1.0'
end
