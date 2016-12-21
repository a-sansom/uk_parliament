module UkParliament
  # Class representing the House of Lords.
  class Lords
    include UkParliament

    # Unique identifier for House of Lords.
    HOUSE_ID = 'lords'
    # URL of where to look for the list of Lords members.
    MEMBER_LIST_URL = 'http://www.parliament.uk/mps-lords-and-offices/lords/'

    # Instance data accessor(s).
    attr_reader :members

    # Initialise the class populating the Lords member data.
    def initialize(load_from_file = false)
      @members = HouseMembersManager.new(HOUSE_ID, load_from_file).members
    end
  end

end