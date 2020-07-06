This includes scripts, templates and links to setup a Rails project.

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
-m https://raw.githubusercontent.com/ombulabs/rails-template/master/template.rb # use the template.rb file from this repo
```

### Downloading the File

You can download the file manually or run this cURL command that will download the file into your HOME dir:

```
curl -o ~/.railsrc https://raw.githubusercontent.com/fastruby/rails-template/master/.railsrc
```


# template.rb

This file is a [Rails Application Tempalte](https://guides.rubyonrails.org/rails_application_templates.html) so we can configure how `rails new` behaves.

### Usage

This file is referenced in the `.railsrc` file so it's used by default in that case. If you are not using the `.railsrc` file but still want to use the template, use this option when creating a new Rails project:

```
rails new PROJECT_NAME -m https://raw.githubusercontent.com/fastruby/rails-template/master/template.rb
```

### What it Does

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

- Maybe move the script to setup the Mac environment to this repository? That script should take care of setting up rvm, ruby version, and could also copy the `.railsrc` file in the HOME dir
- Add `next_rails` gem and config for current and master?
- Maybe ask to select between ombulabs-styleguide, fastruby-styleguide or no styleguide
