module UkParliament
  # Class defining the pipeline process of a scraped member summary document.
  class MemberSummaryDocPipeline < DocPipeline
    # Initialise the class, calling the parent class init, with provided args.
    def initialize(house_id, document)
      super
    end

    # Produce the member summary.
    def enrich_member_data(member)
      @member = member

      execute
    end

    private

    # Define the tasks that will be performed for the commons member summary
    # pipeline.
    def define_commons_tasks
      @commons_tasks = %w(parliamentary_details departmental_details constituency_details digital_details commons_member_name)
    end

    # Define the tasks that will be performed for the lords member summary
    # pipeline.
    def define_lords_tasks
      @lords_tasks = %w(parliamentary_details departmental_details external_office_details digital_details lords_member_name)
    end

    # Extract the parliamentary contact details for a member.
    def parliamentary_details
      nodeset = @document.xpath("//div[contains(@class, 'contact-detail') and contains(@class, 'parliamentary')]")

      if nodeset.length > 0
        section_id = 'parliamentary_contact'
        @member[section_id] = {}
        section_contact_details(section_id, nodeset)
      end
    end

    # Create a container for a particular section of contact details.
    def section_contact_details(section_id, nodeset)
      address = nodeset.at_xpath(".//*[@data-generic-id = 'address']")
      phone_fax = nodeset.at_xpath(".//*[@data-generic-id = 'telephone']")
      email = nodeset.at_xpath(".//*[@data-generic-id = 'email-address']/a/span[@class = '__cf_email__']")

      address(address, section_id)
      phone_fax(phone_fax, section_id)
      email(email, section_id)
    end

    # Extract the address value from a document node.
    def address(node, section_id)
      unless node.nil?
        @member[section_id]['address'] = node.content.strip
      end
    end

    # Extract the phone/fax value(s) from a document node.
    def phone_fax(node, section_id)
      unless node.nil?
        # Some telephone values include a 'Fax' number label/value as well as a
        # 'Tel' number label/value
        if node.content.include?('Fax')
          parts = node.content.strip.gsub(/\s+/, ' ').split(/fax:*\s*/i)
          @member[section_id]['telephone'] = parts[0].gsub(/tel:*\s*/i, '').strip
          @member[section_id]['fax'] = parts[1]
        else
          @member[section_id]['telephone'] = node.content.strip.gsub(/\s+/, ' ').sub(/tel:*\s*/i, '')
        end
      end
    end

    # Extract email value from a document node.
    def email(node, section_id)
      unless node.nil?
        @member[section_id]['email'] = decode_email(node['data-cfemail'])
      end
    end

    # Decode the Cloudflare encoded email address.
    def decode_email(code)
      k = code[0..1].hex

      (2..(code.size - 1)).step(2).to_a.map{ |i|
        (code[i..(i + 1)].hex ^ k).chr
      }.join
    end

    # Extract the constituency contact details for a member.
    def constituency_details
      nodeset = @document.xpath("//div[contains(@class, 'contact-detail') and contains(@class, 'constituency')]")

      if nodeset.length > 0
        section_id = 'constituency_contact'
        @member[section_id] = {}
        section_contact_details(section_id, nodeset)
      end
    end

    # Extract the external office contact details for a member.
    def external_office_details
      nodeset = @document.xpath("//div[contains(@class, 'contact-detail') and contains(@class, 'externalprivate-office')]")

      if nodeset.length > 0
        section_id = 'external_contact'
        @member[section_id] = {}
        section_contact_details(section_id, nodeset)
      end
    end

    # Extract the departmental office contact details for a member.
    def departmental_details
      nodeset = @document.xpath("//div[contains(@class, 'contact-detail') and contains(@class, 'departmental')]")

      if nodeset.length > 0
        section_id = 'departmental_contact'
        @member[section_id] = {}
        section_contact_details(section_id, nodeset)
      end
    end

    # Extract the digital contact details for a member.
    def digital_details
      nodeset = @document.xpath("//div[@id = 'web-social-media']")

      web = nodeset.xpath(".//*[@data-generic-id = 'website']/a")
      twitter = nodeset.at_xpath(".//*[@data-generic-id = 'twitter']/a")
      facebook = nodeset.at_xpath(".//*[@data-generic-id = 'facebook']/a")

      web(web)
      twitter(twitter)
      facebook(facebook)
    end

    # Extract web address value(s) from a document node.
    def web(nodeset)
      unless nodeset.nil? || nodeset.empty?
        @member['web'] = []

        nodeset.each { |node|
          @member['web'] << node['href']
        }
      end
    end

    # Extract Twitter account values from a document node.
    def twitter(node)
      unless node.nil?
        @member['twitter'] = {
          'profile' => node['href'],
          'username' => node.child.content
        }
      end
    end

    # Extract Facebook link value from a document node.
    def facebook(node)
      unless node.nil?
        @member['facebook'] = node['href']
      end
    end

    # Extract a commons member name value from a document node.
    def commons_member_name
      section_id = 'name'
      @member[section_id] = {}

      title_list = %w(Mr Mrs Ms Dr Sir Dame Lady Lord)
      # String: "Abbot, Ms Diane"
      components = @member['alphabetical_name'].split(',')
      # Array: |Abbot| Ms Diane|
      surname = components.shift
      # Array: | Ms Diane|
      components = components.join.split(' ')
      # Array: |Ms|Diane|
      if title_list.include?(components[0])
        @member[section_id]['title'] = components.shift
      end
      # Array: |Diane|
      components << surname
      # Array: |Diane|Abbot|
      @member[section_id]['full_name'] = components.join(' ')
      @member[section_id]['given_name'] = components.shift
      @member[section_id]['surname'] = components.pop

      unless components.empty?
        @member[section_id]['middle_names'] = components
      end
    end

    # Extract a lords member name value from a document node.
    def lords_member_name
      section_id = 'name'
      @member[section_id] = {}

      table = @document.xpath("//table[@class = 'personal-details-container']")

      full_title = table.at_xpath("//div[@id = 'lords-fulltitle']")
      @member[section_id]['full_title'] = full_title.content.strip

      name = table.at_xpath("//div[@id = 'lords-name']")
      components = name.content.strip.split(' ')
      @member[section_id]['full_name'] = components.join(' ')
      @member[section_id]['given_name'] = components.shift
      @member[section_id]['surname'] = components.pop

      unless components.empty?
        @member[section_id]['middle_names'] = components
      end
    end

  end

end