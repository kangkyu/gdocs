# Gdocs

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/gdocs`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add gdocs

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install gdocs

## Usage

As of today, we only have `Gdocs::Models::Document#title`
```rb
require 'gdocs'

d = Gdocs::Models::Document.new('1IlgYRWw2Vo4DJLYg53_AyZxWeFsgohoV-wZ_pdWLBio')
d.run_request if ENV['GDOCS_AUTH_TOKEN']
puts d.title
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kangkyu/gdocs.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
