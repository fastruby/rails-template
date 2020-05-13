This includes scripts, templates and links to set up a development environment

# Usage

This project provides an `rc` file that you can use when creating new rails projects with some defaults. If you put the `.railsrc` file in your HOME directory, you can simply run the `rails new` command and it will use that file's content:

```
rails new projectname
```

If you want to put the `rc` file somewhere else and with another name, you can use the `--rc=path` argument to target that file:

```
rails new projectname --rc=/some/path/to/myrailsrc
```

### Notes

- You can use any standard `rails new` command arguments (run `rails new --help` for more)
- You can still override the predefined `.railsrc` arguments. If, for example, you want to use MySQL, you can still do `rails new some_project --database=mysql` that will override the default
- The `rc` file can be ignored completely using the flag `--no-rc` in case you want to ignore all the defaults for a given project (`rails new some_project --no-rc`)

# .railsrc

The file includes different arguments that will be used as default for things that can't be properly configured with a rails-template. Each argument goes in a new line.

### What it does

This file contains these lines:

```
--skip-bundle # don't run bundle, we want to modify the gemfile first
--skip-test # skip minitest gem setup, we are using rspec
--skip-turbolinks # don't add Turbolinks gem to the project
--database=postgresql # use postgres instead of sqlite
-m https://raw.githubusercontent.com/ombulabs/rails-template/master/template.rb # use the template.rb file from this repo
```

### Notes

- Right now the template reference won't work since the project is private, so you have to copy the `template.rb` file somewhere on your computer and fix that path in the `.railsrc` file to actually target that local file or us the `-m` argument manually to override the `.railsrc` template setting (this should just work when we make this public)


# template.rb

This file is a [Rails Application Tempalte](https://guides.rubyonrails.org/rails_application_templates.html) so we can configure how `rails new` behaves.

This file is references in the `.railsrc` file.

### What it does

This file sets a few gems and configure them:
- [ombulabs-styleguide](https://github.com/ombulabs/styleguide)
- [rspec](https://relishapp.com/rspec) (via rspec-rails)
- [factory_bot](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md)
- [simplecov](https://github.com/colszowka/simplecov)
- [dotenv](https://github.com/bkeepers/dotenv) (via dotenv-rails)
- [pagy](https://github.com/ddnexus/pagy)
- [standard](https://github.com/testdouble/standard)

Each line (or group of lines) have a comment in that file explaining it's purpose.

# More Resources

- Standard code editor integration: https://github.com/testdouble/standard/wiki

# TODO

- Make this repo public so the `template.rb` file can be referenced by the `.railsrc` file with no modifications (check `.railsrc` notes)
- Maybe move the script to setup the Mac environment to this repository? That script should take care of setting up rvm, ruby version, and could also copy the `.railsrc` file in the HOME dir
- Provide a curl/wget command to download the `.railsrc` file into the HOME directory
- Add `next_rails` gem and config for current and master?
- Maybe ask to select between ombulabs-styleguide, fastruby-styleguide or no styleguide
