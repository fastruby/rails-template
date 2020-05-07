# gemfile already includes rails
# gemfile already includes capybara
# gemfile already includes selenium-webdriver
# gemfile already includes webdrivers

# this is done so it due to a conflict with sass-rails 6 and the styleguide
gsub_file "Gemfile", /^gem\s+["']sass-rails["'].*$/, 'gem "sass-rails"' # remove version restriction
gem "ombulabs-styleguide", github: "ombulabs/styleguide", branch: "gh-pages"

# spec related
gem "rspec-rails", group: "test"
gem 'factory_bot_rails', group: [:development, :test]
gem 'simplecov', require: false, group: :test

# code style
gem "standard", group: [:development, :test]

# environment
gem "dotenv-rails"

# Install everything
run "bundle install"

# Install rspec
generate "rspec:install"

# Set up the spec folders for RSpec
run "mkdir spec/models"
run "mkdir spec/controllers"
run "mkdir spec/system"
run "mkdir spec/views"
run "mkdir spec/routes"
run "mkdir spec/jobs"
run "mkdir spec/helpers"
run "mkdir spec/mailers"

# New folder for factories
run "mkdir spec/factories"

# Add simplecov configuration
inject_into_file "spec/spec_helper.rb", before: "RSpec.configure do |config|\n" do <<-'RUBY'
require "simplecov"
SimpleCov.start

RUBY
end

# Add `rails spec` task to run our tests
inject_into_file 'Rakefile', before: "Rails.application.load_tasks\n" do <<-'RUBY'
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

RUBY
end

# Show a message to the developer for code editor linter config
puts "#####################"
puts ""
puts "To use Standard code style linter:"
puts "Go to https://github.com/testdouble/standard#how-do-i-run-standard-in-my-editor and set up your code editor"
puts ""
puts "#####################"