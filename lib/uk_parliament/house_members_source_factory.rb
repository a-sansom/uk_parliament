module UkParliament
  # Factory taking responsibility for instantiating correct data source class
  # for a given data source ID/house ID pair.
  class HouseMembersSourceFactory
    # Create correct type of class for the IDs passed in.
    def self.init_data_source(data_source_id, house_id)
      source = nil

      if data_source_id == DATA_SOURCE_FILE
        source = FileHouseMembers.new(house_id)
      elsif data_source_id == DATA_SOURCE_HTTP
        source = HttpHouseMembers.new(house_id)
      end

      source
    end
  end
end