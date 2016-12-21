module UkParliament
  # Manages creation of the correct member data source class and makes the
  # member data available to the caller.
  class HouseMembersManager
    include UkParliament

    attr_reader :members

    # Create the factory class instance and return its member data.
    def initialize(house_id, load_from_file)
      log.info('------------------------------------------------------------')
      data_source_id = load_from_file ? DATA_SOURCE_FILE : DATA_SOURCE_HTTP
      log.info("Using '#{data_source_id}' data source for '#{house_id}' members")
      source = HouseMembersSourceFactory.init_data_source(data_source_id, house_id)
      log.info("'#{house_id}' has #{source.members.size} members")
      @members = source.members
    end
  end
end