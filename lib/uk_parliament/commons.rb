module UkParliament
  # Class representing the House of Commons.
  class Commons
    include UkParliament

    # Unique identifier for House of Commons.
    HOUSE_ID = 'commons'
    # URL of where to look for the list of Commons members.
    MEMBER_LIST_URL = 'http://www.parliament.uk/mps-lords-and-offices/mps/'

    # Instance data accessor(s).
    attr_reader :members

    # Initialise the class populating the Commons member data.
    def initialize(load_from_file = false)
      @members = HouseMembersManager.new(HOUSE_ID, load_from_file).members
    end
  end

end