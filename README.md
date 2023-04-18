[![Gem](https://img.shields.io/gem/v/gdocs)](https://rubygems.org/gems/gdocs)

# Gdocs

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/gdocs`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add gdocs

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install gdocs

## Usage

As of today, we only have `Gdocs::Models::Document#run_get` and `Gdocs::Models::Document#run_create`
```rb
require 'gdocs'

d = Gdocs::Models::Document.new("ya29.a0Aa4xrXO...")
d.run_create(title: "Jimmy's Report")
d.document_id
# => "1qpN_MR_i1rnu7-MD03JKUGlTvOT2GFgr5uyhhsvJ2Z8"

d.run_get('1qpN_MR_i1rnu7-MD03JKUGlTvOT2GFgr5uyhhsvJ2Z8')
d.title
# => "Jimmy's Report"

d.text_to_body("Ali Baba and the Forty Thieves\n")
d.text_to_body("\"I liked it\"\n")

d.text_to_body("Look at this table", font: "Source Code Pro")
d.table_to_body(6, 8)

# check your file!
# https://docs.google.com/document/d/1qpN_MR_i1rnu7-MD03JKUGlTvOT2GFgr5uyhhsvJ2Z8/edit
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kangkyu/gdocs.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
