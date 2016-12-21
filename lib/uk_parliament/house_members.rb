require 'fileutils'
require 'json'

module UkParliament
  class HouseMembers
    include UkParliament

    attr_reader :members

    def initialize(house_id)
      @house_id = house_id
      @members = []
      @config = configuration
      @backup = @config[:backup_before_write]
    end

    protected

    # Load a house's .json file from disk.
    def load_file
      filename = File.join(@config[:data_file_path], "#{@house_id}.json")
      raise "'#{filename}' Does not exist. Have you scraped '#{@house_id}' data yet? See README" unless File.exist?(filename)
      json = File.read(filename)
      @members = JSON.parse(json)
    end

    # Save a new version of a house's .json file to disk, optionally backing
    # up any previous file beforehand.
    def save_file
      if @backup
        backup_file
      end

      filename = File.join(@config[:data_file_path], "#{@house_id}.json")
      File.open(filename, 'w') do |json_file|
        json_file.write(JSON.pretty_generate(@members))
      end

      log.info("'#{@house_id}' saved to file")
    end

    # Back up an existing house's .json file.
    def backup_file
      filename = File.join(@config[:data_file_path], "#{@house_id}.json")

      if File.exist?(filename)
        backup_filename = "#{filename.split('.')[0]}-#{File.mtime(filename).strftime('%Y%m%d_%H%M%S')}.json"
        FileUtils.cp(filename, backup_filename)
        log.info("Previous '#{@house_id}' file was backed up")
      end
    end
  end
end