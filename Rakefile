require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "uk_parliament"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :scrape_parliament do
  puts 'Scraping Parliament data'
  puts 'This will take some time, approx. 10 mins'
  puts "Check/tail the log file in your user '$HOME/uk_parliament' directory for progress."
  parliament = UkParliament::Parliament.new(false, false)
  puts "Finished scraping. Check user '$HOME/uk_parliament' directory for .json files."
end