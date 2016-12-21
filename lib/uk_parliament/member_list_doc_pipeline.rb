module UkParliament
  # Class defining the pipeline process of a scraped member list document.
  class MemberListDocPipeline < DocPipeline
    # Initialise the class, calling the parent class init, with provided args.
    def initialize(house_id, document)
      super
    end

    # Produce the list of members for the relevant house.
    def house_member_list(members)
      @members = members

      execute
    end

    private

    # Define the tasks that will be performed for the commons member list
    # pipeline.
    def define_commons_tasks
      @commons_tasks = %w(commons_members)
    end

    # Define the tasks that will be performed for the lords member list
    # pipeline.
    def define_lords_tasks
      @lords_tasks = %w(lords_members)
    end

    # Process House of Commons member list document data, pulling out each
    # member's basic data and appending to a list of members.
    def commons_members
      table_rows = @document.xpath("//tr[descendant::a[starts-with(@href, 'http://www.parliament.uk/biographies/commons/')]]")

      table_rows.each do |row|
        member = {}

        name = row.at_xpath('./td[1]/a')
        first_cell_text = row.xpath('./td[1]//text()')
        constituency = row.at_xpath('./td[2]')

        member_name(member, name)
        member_profile_url(member, name)
        member_id(member, name)
        commons_party(member, first_cell_text)
        commons_constituency(member, constituency)

        @members << member
      end
    end

    # Process House of Lords member list document data, pulling out each
    # member's basic data and appending to a list of members.
    def lords_members
      table_rows = @document.xpath("//tr[descendant::a[starts-with(@href, 'http://www.parliament.uk/biographies/lords/')]]")

      table_rows.each do |row|
        member = {}

        name = row.at_xpath('./td[1]/a')
        party = row.at_xpath('./td[2]')

        member_name(member, name)
        member_profile_url(member, name)
        member_id(member, name)
        lords_party(member, party)

        @members << member
      end
    end

    # Extract member name data from a document node.
    def member_name(member, node)
      member['alphabetical_name'] = node.content
    end

    # Extract member summary URL data from a document node.
    def member_profile_url(member, node)
      member['url'] = node['href']
    end

    # Extract member ID data from a document node.
    def member_id(member, node)
      member['id'] = node['href'].split('/').last.to_i
    end

    # Extract Commons member party from a document node.
    def commons_party(member, nodeset)
      member['party'] = nodeset.last.to_s.strip[1..-2]
    end

    # Extract a Commons member constituency from a document node.
    def commons_constituency(member, node)
      member['constituency'] = node.content
    end

    # Extract Lords member party or group from a document node.
    def lords_party(member, node)
      member['party_or_group'] = node.content
    end
  end

end