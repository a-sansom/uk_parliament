require 'uk_parliament/version'
require 'uk_parliament/commons'
require 'uk_parliament/doc_pipeline'
require 'uk_parliament/house_members'
require 'uk_parliament/file_house_members'
require 'uk_parliament/house_members_manager'
require 'uk_parliament/house_members_source_factory'
require 'uk_parliament/http_house_members'
require 'uk_parliament/lords'
require 'uk_parliament/member_list_doc_pipeline'
require 'uk_parliament/member_summary_doc_pipeline'
require 'uk_parliament/queue_manager'
require 'logger'

# Module defining classes and methods enabling scraping of UK Parliament
# members contact data from parliament.uk web site, or loading of scraped
# data from file.
module UkParliament
  # Constants representing where data can come from.
  DATA_SOURCE_FILE = 'file'
  DATA_SOURCE_HTTP = 'http'

  # Setup module-wide access to Log to file.
  def log
    UkParliament.log
  end

  # Setup a Logger instance, if one doesn't already exist.
  def self.log
    if @log.nil?
      config = configuration
      @log = Logger.new(File.join(config[:log_file_path], 'uk_parliament.log'), 'daily')
      @log.level = Logger::INFO
    end

    @log
  end

  # Setup module-wide access to a set of configuration values.
  def configuration
    UkParliament.configuration
  end

  # Define set of configuration values for the module.
  def self.configuration
    if @configuration.nil?
      base_dir = File.join(Dir.home, 'uk_parliament')
      FileUtils.mkdir_p(base_dir) unless Dir.exist?(base_dir)

      @configuration = {
        :log_file_path => base_dir,
        :data_file_path => base_dir,
        :queue_file_path => base_dir,
        :scrape_no_of_threads => 4,
        :scrape_request_delay => 2,
        :backup_before_write => true
      }
    end

    @configuration
  end

  # Class representing Parliament.
  class Parliament
    include UkParliament

    # Instance data accessor(s).
    attr_reader :houses

    # Initialise the class instance variables.
    def initialize(load_commons_file = true, load_lords_file = true)
      @houses = {
        :commons => Commons.new(load_commons_file),
        :lords => Lords.new(load_lords_file)
      }
    end

    # Simple lookup of members with a particular name (or part of).
    def parliamentarians_named(search_name)
      search_name = search_name.strip.downcase
      results = []

      if search_name.size > 1
        @houses.each_value { |house_data|
          house_data.members.each { |member|
            if member.key?('name')
              if member['name']['full_name'].downcase.include?(search_name)
                results << member
              end
            end
          }
        }
      end

      results
    end
  end

end
