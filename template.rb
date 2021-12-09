# gemfile already includes rails

require "net/http"

# downloads the content of a file from github config_files dir
# used to copy configuration files like .reek.yml or the branding hook
def get_gh_file_content(filename)
  uri = "https://raw.githubusercontent.com/fastruby/rails-template/main/config_files/#{filename}"
  Net::HTTP.get(URI(uri))
end

# select which styleguide to use (or none), defaults to ombulabs' one
puts "Which style guide do you want to use? (default: ombulabs)"
puts "Possible values: '(o)mbulabs', '(f)astruby', '(n)one', leave empty for (o)mbulabs"
styleguide_answer = ask("Use: ")
styleguide =
  case styleguide_answer.downcase
  when "n", "none" then nil
  when "o", "ombulabs", "" then "ombulabs"
  when "f", "fastruby" then "fastruby"
  else
    puts "Unknown styleguide: '#{styleguide_answer}'"
  end

# setup ombulabs styleguide gem if needed
if styleguide == "ombulabs"
  # this is done due to a conflict with sass-rails 6 and the styleguide gem
  gsub_file "Gemfile", /^gem\s+["']sass-rails["'].*$/, 'gem "sass-rails"' # remove version restriction
  gem "ombulabs-styleguide", github: "ombulabs/styleguide", branch: "gh-pages"
end

# add other gems
gem_group :development do
  gem "guard-rspec", require: false
end

# spec and linter related
gem_group :test do
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "rspec-rails"
end

gem_group :development, :test do
  gem "factory_bot_rails"
  gem "simplecov", require: false
  gem "standard" # code style linter
  gem "rubocop-rspec" # rspec rules for rubocop
  gem "rubocop-rails" # rails rules for rubocop
  gem "reek" # code smells linter
  gem "overcommit", "0.57.0" # run linters when trying to commit
  gem "next_rails"
end

# environment
gem "dotenv-rails"
gem "dotenv_validator"
initializer '1_dotenv_validator.rb', "DotenvValidator.check!"

# pagination
gem "pagy"

# DO THIS AFTER ALL GEMS ARE SET
# Replace 'string' with "string" in the Gemfile so RuboCop is happy
gsub_file "Gemfile", /'([^']*)'/, '"\1"'

# Install gems
run "bundle install"

# Setup RSpec and test related config
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
require "capybara/rails"
Capybara.server = :puma, { Silent: true }

RUBY
end

# Add `rails spec` task to run our tests
inject_into_file "Rakefile", before: "Rails.application.load_tasks\n" do <<-'RUBY'
begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

RUBY
end

# Add styleguide's css and js if needed
case styleguide
when "ombulabs"
  inside("app/assets/stylesheets") do
    run "mv application.css application.scss"
    append_to_file "application.scss" do
      %Q(
@import "ombulabs/styleguide";
)
    end
  end
when "fastruby"
  inside("app/assets/stylesheets") do
    run "mv application.css application.scss"
    append_to_file "application.scss" do
      %Q(
@import "fastruby-io-styleguide";
)
    end
  end

  inside("app/javascript/packs") do
    append_to_file "application.js" do
      %Q(
import "fastruby-io-styleguide"
)
    end
  end
end

# include Pagy helpers and create initializer
inject_into_file "app/controllers/application_controller.rb", after: "class ApplicationController < ActionController::Base\n" do <<-'RUBY'
  include Pagy::Backend
RUBY
end

inject_into_file "app/helpers/application_helper.rb", after: "module ApplicationHelper\n" do <<-'RUBY'
  include Pagy::Frontend
RUBY
end

initializer "pagy.rb", <<-CODE
# copy https://github.com/ddnexus/pagy/blob/3.8.1/lib/config/pagy.rb here and customize if needed
CODE

# install webpacker
rake "webpacker:install"

# if styleguide is fastruby, add the yarn package too
if styleguide == "fastruby"
  system("yarn add fastruby/styleguide#gh-pages")
end

# init guard with rspec config
system("bundle exec guard init rspec")

# remove the .ruby-version file to use the version from the Gemfile
run "mv .ruby-version .ruby-version.sample"

# create a sample database.yml instead of a real one
run "mv config/database.yml config/database.yml.sample"

# make bin/setup run yarn too
gsub_file "bin/setup", "# system('bin/yarn')", "system('bin/yarn')"

# make bin/setup move sample files to new locations
inject_into_file "bin/setup", after: %r{system!?.'bin/yarn'.?\n} do <<-'RUBY'

  # Install overcommit hooks
  system("overcommit --install")

  # install StandardJS so it can be used by overcommit
  system("npm install standard --global")

  # sets a specific version of node that we know works fine with webpacker
  # you can remove it if you need to
  [".nvmrc", ".node-version"].each do |file_name|
    File.open(file_name, "w") do |f|
      f.write "12.18.3\n"
    end
  end

  # sets the .ruby-version file, RVM prioritizes this instead of the Gemfile
  # can be removed
  FileUtils.cp ".ruby-version.sample", ".ruby-version"

  # copy database.yml sample
  FileUtils.cp "config/database.yml.sample", "config/database.yml"

  # copy .env file
  unless File.exist?(".env") 
    puts "\n== Copying .env file"
    FileUtils.cp ".env.sample", ".env" 
  end
RUBY
end

# Initialize Gemfile.next for dual boot
run "next --init"

# Add dual-boot in Gemfile 
next_gem = '''
if next?
  gem "rails", github: "rails/rails", branch: "main"
else
  gem "rails", \1
end
'''

# Update Gemfile
# gsub_file("Gemfile", /^gem\s+["']rails["'].*$/, next_gem)
gsub_file("Gemfile", /^gem\s+["']rails["'],\s+(["'].*["']).*$/, next_gem)

run "next bundle install"

# add a blank .env.sample file
create_file ".env.sample"

# add suggested reek config for Rails applications
create_file ".reek.yml", get_gh_file_content(".reek.yml")

# add config for Overcommit (set it to do a few checks and run standardrb and reek)
create_file ".overcommit.yml", get_gh_file_content(".overcommit.yml")

# add RuboCop config
create_file ".rubocop.yml", get_gh_file_content(".rubocop.yml")

# adds the branding pre commit hook
create_file ".git-hooks/pre_commit/branding.rb", get_gh_file_content("branding_pre_commit_hook.rb")

# adds the wording pre commit hook
create_file ".git-hooks/pre_commit/wording.rb", get_gh_file_content("wording_pre_commit_hook.rb")

# adds the github action for rspec
create_file ".github/workflows/main.yml", get_gh_file_content("github_actions_main.yml")
create_file ".github/workflows/rails_next.yml", get_gh_file_content("github_actions_rails_next.yml")

# adds x86_64-linux platform in the Gemfile.lock
run "bundle lock --add-platform x86_64-linux"

# add PR template
create_file ".github/pull_request_template.md", get_gh_file_content("pull_request_template.md")

# ignore some files for git
append_file ".gitignore" do <<-'GIT'
.env
.nvmrc
.node-version
.ruby-version
/config/database.yml
GIT
end

# Stop spring to clear the preloded cache 
run "bundle exec spring stop"

# Fix Rubocop Offences
gsub_file("config/environments/development.rb", "Rails.root.join\('tmp', 'caching-dev.txt'\).exist\?", 'Rails.root.join("tmp/caching-dev.txt").exist?')
run "rubocop -A"

# Show a message to the developer for code editor linter config
puts "#####################"
puts ""
puts "We use Rubocop with the StandardRB rules, but we need to set RuboCop as the linter to be able to use extensions"
puts "Go to https://docs.rubocop.org/rubocop/0.92/integration_with_other_tools.html and set up your code editor"
puts ""
puts "There's also Reek support for some editor:"
puts "vscode-ruby extension"
puts "https://github.com/fastruby/linter-reek and others for atom"
puts ""
puts "#####################"
