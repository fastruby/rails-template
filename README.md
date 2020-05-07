This includes scripts, templates and links to set un a development environment

# .railsrc

Everything you run `rails new some_project`, Rails will read that `.railsrc` file and add the content as options for the command so you don't have to manually set those.

The file must be on your HOME dir.

### What it does

This file contains these lines:

```
--skip-bundle  # don't run bundle, we want to modify the gemfile first
--skip-test-unit # skip minitest gem setup, we are using rspec
--database=postgresql # use postgres instead of sqlite
-m https://github.com/ombulabs/rails-template/blob/master/template.rb # use the template.rb file from this repo
```

### Notes

- Run `rails new --help` for more options
- We can still override `.railsrc` flags. If, for example, we want to use MySQL, we can still do `rails new some_project --database=mysql`
- The `rc` file can be ignored using the flag `--no-rc` (`rails new some_project --no-rc`)
- If you want to put the `rc` file somewhere, you can use the `--rc=path` flag with the correct path
- Right now the template reference won't work since the project is private, so you have to copy the `template.rb` file somewhere on your computer and fix that path in the `.railsrc` file to actually target that local file or us the `-m` flag manually to override the `.railsrc` template setting

# template.rb

This file is an [Application Tempalte](https://guides.rubyonrails.org/rails_application_templates.html) so we can configure how `rails new` behaves.

This file is references in the `.railsrc` file.

### What it does

This file sets a few gems:
- ombulabs-styleguide
- rspec (via rspec-rails)
- factory_bot
- simplecov
- dotenv (via dotenv-rails)

Also configures rspec and simplecov.

Each line (or group of lines) have a comment in that file explaining it's purpose.

# Resources

- Standard: https://github.com/testdouble/standard (check wiki for code editor config)
- Rspec: https://relishapp.com/rspec


# TODO

- Make this repo public so the `template.rb` file can be referenced by the `.railsrc` file with no modifications (check `.railsrc` notes)
- Maybe move the script to setup the Mac environment to this repository? That script should take care of setting up rvm, ruby version, and could also copy the `.railsrc` file in the HOME dir
- Add `next_rails` gem and config for current and master?
- Maybe ask to select between ombulabs-styleguide, fastruby-styleguide or no styleguide
