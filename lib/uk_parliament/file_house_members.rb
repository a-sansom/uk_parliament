module UkParliament
  # Class to load house member data from file.
  class FileHouseMembers < HouseMembers
    # Initialise the parent and load the correct file.
    def initialize(house_id)
      super

      load_file
    end
  end
end