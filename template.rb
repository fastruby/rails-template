# gemfile already includes rails

# this is done so it due to a conflict with sass-rails 6 and the styleguide
gsub_file "Gemfile", /^gem\s+["']sass-rails["'].*$/, 'gem "sass-rails"' # remove version restriction
gem "ombulabs-styleguide", github: "ombulabs/styleguide", branch: "gh-pages"

# spec related
gem_group :test do
  gem "capybara", '>= 2.15'
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "rspec-rails"
end

gem_group :development, :test do
  gem 'factory_bot_rails'
  gem 'simplecov', require: false
  gem "standard" # code style
end

# environment
gem "dotenv-rails"

# pagination
gem 'pagy', '~> 3.8'

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

# Add simplecov and rspec configuration
inject_into_file "spec/spec_helper.rb", before: "RSpec.configure do |config|\n" do <<-'RUBY'
require "simplecov"
SimpleCov.start

RUBY
end

# Add simplecov and rspec configuration
inject_into_file "spec/rails_helper.rb", before: "require 'rspec/rails'\n" do <<-'RUBY'
require 'capybara/rails'
Capybara.server = :puma, { Silent: true }

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

# Add styleguide css
inside('app/assets/stylesheets') do
  run "mv application.css application.scss"
  append_to_file 'application.scss' do
    '@import "ombulabs/styleguide";'
  end
end

# include Pagy helpers and create initializer
inject_into_file 'app/controllers/application_controller.rb', after: "class ApplicationController < ActionController::Base\n" do <<-'RUBY'
  include Pagy::Backend
RUBY
end

inject_into_file 'app/helpers/application_helper.rb', after: "module ApplicationHelper\n" do <<-'RUBY'
  include Pagy::Frontend
RUBY
end

initializer "pagy.rb", <<-CODE
# copy https://github.com/ddnexus/pagy/blob/3.8.1/lib/config/pagy.rb here and customize if needed
CODE

# Show a message to the developer for code editor linter config
puts "#####################"
puts ""
puts "To use Standard code style linter:"
puts "Go to https://github.com/testdouble/standard#how-do-i-run-standard-in-my-editor and set up your code editor"
puts ""
puts "#####################"