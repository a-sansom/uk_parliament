# UkParliament

Gem that scrapes current UK parliamentarians (members of the House of Commons and House of Lords) contact details (addresses, phone, email, Twitter, Facebook etc) from the [parliament.uk](http://parliament.uk) web site and stores the data to file(s) in JSON format.

Each member of the House of Commons and House of Lords has a publicly available profile on the parliament.uk site. Each profile contains varying amounts of contact information, so results of each member will differ.

Why scrape this info? Yes, there is an API, but it doesn't/didn't appear particularly straight forward to get the contact info required.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'uk_parliament'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install uk_parliament

## Usage



Trigger scraping of data, so it can be saved to file, either, a) by running a Rake task:

    rake scrape_parliament

Or b), by opening `bin/console` and running:

    parliament = UkParliament::Parliament.new(false, false)

This will run for approx. 7-10 minutes (depending on machine/network etc.) and output two files, `commons.json` and `lords.json` in the user `$HOME/uk_parliament` directory.

Progress of the data being scraped is output to a log file, `uk_parliament.log`, also in the user `$HOME/uk_parliament` directory.

To monitor progress, run:

    tail -f ~/uk_parliament/uk_parliament.log

The log will tell you which, if any, requests fail, and at the end tell you how many have failed.

If there are failures, they are recorded in an error queue. You just need to re-run the same command again, and the contents of the error queue will be used as the source of what to scrape, rather than attempting to scrape the whole set of data again.

The successfully scraped errors will be merged with previous data in the JSON file(s).

Errors appear to be few and intermittent. Keep reprocessing the error queue until it is empty.

Each time you re-run the scraping, the output of the previous run (the `*.json` files) will be backed up, with the timestamp from when they were created. Eg. `commons.json` will become `commons-20161231_061221.json`

Once you have created the output files, running:

    parliament = UkParliament::Parliament.new

or:

    parliament = UkParliament::Parliament.new(true, true)

will load the data from those files for you to process as you wish.

For example, you can access just the members of the House of Commons data with:

    parliament.houses[:commons].members

The first entry in that list of members is then:

    irb(main):013:0> parliament.houses[:commons].members[0]
    => {"alphabetical_name"=>"Abbott, Ms Diane", ...}

For quick results, there is a _very_ basic member name lookup that can be run with:

    irb(main):007:0> parliament.parliamentarians_named('Ahmed')
    => [{"alphabetical_name"=>"Ahmed-Sheikh, Ms Tasmina", ...}, {"alphabetical_name"=>"Ahmed, Lord", ...}]

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/a-sansom/uk_parliament](https://github.com/a-sansom/uk_parliament).

