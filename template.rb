# gemfile already includes rails

puts "Which style guide do you want to use? (default: ombulabs)"
puts "Possible values: 'o', 'ombulabs', 'n', 'none', leave empty"
styleguide_answer = ask("Use: ")
styleguide =
  case styleguide_answer.downcase
  when "n", "none" then nil
  when "o", "ombulabs", "" then "ombulabs"
  else
    puts "Unknown styleguide: '#{styleguide_answer}'"
  end

# this is done due to a conflict with sass-rails 6 and the styleguide
gsub_file "Gemfile", /^gem\s+["']sass-rails["'].*$/, 'gem "sass-rails"' # remove version restriction

if styleguide == "ombulabs"
  gem "ombulabs-styleguide", github: "ombulabs/styleguide", branch: "gh-pages"
# elsif styleguide == "fastruby"
#   gem "fastruby-styleguide", github: "fastruby/styleguide", branch: "gh-pages"
end

# spec  and linter related
gem_group :test do
  gem "capybara", '>= 2.15'
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "rspec-rails"
end

gem_group :development, :test do
  gem 'factory_bot_rails'
  gem 'simplecov', require: false
  gem "standard" # code style linter
  gem "reek" # code smells linter
  gem "rails_best_practices" # rails bad practices linter
  gem 'overcommit' # run linters when trying to commit
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

# Add styleguides' css if present
if styleguide
  inside('app/assets/stylesheets') do
    run "mv application.css application.scss"
    append_to_file 'application.scss' do
      %Q(@import "#{styleguide}/styleguide";)
    end
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

# install webpacker
rake "webpacker:install"

# remove the .ruby-version file to use the version from the Gemfile
run "mv .ruby-version .ruby-version.sample"

# make bin/setup run yarn
gsub_file "bin/setup", "# system('bin/yarn')", "system('bin/yarn')"

inject_into_file 'bin/setup', after: "system('bin/yarn')\n" do <<-'RUBY'

  # Install overcommit hooks
  system('overcommit --install')

  # install StandardJS so it can be used by overcommit
  system('npm install standard --global')

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
RUBY
end

# add suggested reek config for Rails applications
create_file ".reek.yml" do <<-'YML'
directories:
  "app/controllers":
    IrresponsibleModule:
      enabled: false
    NestedIterators:
      max_allowed_nesting: 2
    UnusedPrivateMethod:
      enabled: false
    InstanceVariableAssumption:
      enabled: false
    TooManyInstanceVariables:
      enabled: false
  "app/helpers":
    IrresponsibleModule:
      enabled: false
    UtilityFunction:
      enabled: false
  "app/mailers":
    InstanceVariableAssumption:
      enabled: false
  "app/models":
    InstanceVariableAssumption:
      enabled: false

YML
end

# add config for Overcommit (set it to do a few checks and run standardrb, reek and rails_best_practices)
create_file ".overcommit.yml" do <<-'YML'
CommitMsg:
  CapitalizedSubject:
    enabled: false

  EmptyMessage:
    enabled: false

  TrailingPeriod:
    enabled: true

  TextWidth:
    enabled: false

PreCommit:
  ALL:
    on_warn: fail

  AuthorEmail:
    enabled: true

  AuthorName:
    enabled: true

  MergeConflicts:
    enabled: true

  YamlSyntax:
    enabled: true

  BundleCheck:
    enabled: true

  RuboCop:
    enabled: true
    command: ["bundle", "exec", "standardrb"]

  Reek:
    enabled: true

  RailsBestPractices:
    enabled: true

  Standard:
    enabled: true

YML
end

# ignore some files for git
append_file '.gitignore' do <<-'GIT'
.nvmrc
.node-version
.ruby-version
GIT
end

# Show a message to the developer for code editor linter config
puts "#####################"
puts ""
puts "To use Standard code style linter in your browser:"
puts "Go to https://github.com/testdouble/standard#how-do-i-run-standard-in-my-editor and set up your code editor"
puts ""
puts "There's also Reek support for some editor:"
puts "vscode-ruby extension"
puts "https://github.com/AtomLinter/linter-reek and others for atom"
puts ""
puts "#####################"