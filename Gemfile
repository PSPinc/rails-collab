source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in collab.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
gem 'byebug', group: [:development, :test]

gem "pg", "~> 1.2"

group *%i(development test) do
  # ops support
  gem 'bundler-audit'

  # rubocop
  # NOTE: codeclimate channels only support up to 1.18.3 as of this commit
  gem 'rubocop', '~> 1.18.3'
  gem 'rubocop-faker', '~> 1.0.0'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
end
