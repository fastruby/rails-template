This includes scripts, templates and links to setup a Rails project.

## Requirements

For newer Rails applications, the default JS assets manager is Webpack (through the Webpacker gem), so any modern Rails app requires [Yarn](https://classic.yarnpkg.com/en/docs/install) as a dependency.

# Usage

This project provides an `rc` file that you can use when creating new rails projects with some defaults. If you put the `.railsrc` file in your HOME directory, you can simply run the `rails new` command and it will use that file's content:

```
rails new projectname
```

If you want to put the `rc` file somewhere else and with another name, you can use the `--rc=path` option to target that file:

```
rails new projectname --rc=/some/path/to/myrailsrc
```

### Notes

- You can use any standard `rails new` command options (run `rails new --help` for details)
- You can still override the options defined in the `.railsrc` file. If, for example, you want to use MySQL, you can still do `rails new some_project --database=mysql` that will override the default
- The `rc` file can be ignored completely using the option `--no-rc` in case you want to ignore all the defaults for a given project (`rails new some_project --no-rc`)

# .railsrc

The file includes default options that will be used when creating a new rails app. These options cannot be handled by a Rails Application Template, both the RC file and the template are needed. Each option goes in a new line.

### What it Does

This file contains these lines:

```
--skip-bundle # don't run bundle, we want to modify the gemfile first
--skip-test # skip minitest gem setup, we are using rspec
--skip-turbolinks # don't add Turbolinks gem to the project
--database=postgresql # use postgres instead of sqlite
--skip-webpack-install # skip webpacker install, we want to run this in a particular order
-m https://raw.githubusercontent.com/ombulabs/rails-template/main/template.rb # use the template.rb file from this repo
```

### Downloading the File

You can download the file manually or run this cURL command that will download the file into your HOME dir:

```
curl -o ~/.railsrc https://raw.githubusercontent.com/fastruby/rails-template/main/.railsrc
```


# template.rb

This file is a [Rails Application Template](https://guides.rubyonrails.org/rails_application_templates.html) so we can configure how `rails new` behaves.

### Usage

This file is referenced in the `.railsrc` file so it's used by default in that case. If you are not using the `.railsrc` file but still want to use the template, use this option when creating a new Rails project:

```
rails new PROJECT_NAME -m https://raw.githubusercontent.com/fastruby/rails-template/main/template.rb
```

### What it Does

This file sets a few gems and tools, and configure them:
- [ombulabs-styleguide](https://github.com/ombulabs/styleguide)
- [rspec](https://relishapp.com/rspec) (via rspec-rails)
- [factory_bot](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md)
- [simplecov](https://github.com/colszowka/simplecov)
- [dotenv](https://github.com/bkeepers/dotenv) (via dotenv-rails)
- [pagy](https://github.com/ddnexus/pagy)
- [rubocop (with standardrb config)](https://github.com/testdouble/standard)
- [rubocop-ombu_labs](https://github.com/fastruby/rubocop-ombu_labs)
- [reek](https://github.com/troessner/reek)
- [overcommit](https://github.com/sds/overcommit)
- [StandardJS](https://github.com/standard/standard)

Each line (or group of lines) have a comment in that file explaining its purpose.

As a summary, it sets gems related to the styleguide, for tests, for linters and code quality and modifies config files.

# Notes on Overcommit (git pre-commit hooks)

We don't want the linters to run for all the rails generated files (many of them won't pass the linter's checks but we don't want to modify internal files), so you can commit all the files before running the bin/setup script (overcommit won't be installed yet) or, if already run, you should disable it for the initial commit. To do so run:

```bash
OVERCOMMIT_DISABLE=1 git commit -a -m "Initial commit"
```

# More Resources

- Standard code editor integration: https://github.com/testdouble/standard/wiki

# TODO

- Maybe move the script to setup the Mac environment to this repository? That script should take care of setting up rvm, ruby version, and could also copy the `.railsrc` file in the HOME dir
- Add `next_rails` gem and config for current and master?
- Maybe ask to select between ombulabs-styleguide, fastruby-styleguide or no styleguide
