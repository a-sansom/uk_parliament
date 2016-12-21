require 'nokogiri'
require 'open-uri'
require 'thread'

module UkParliament
  # Class to load house member data from the web.
  class HttpHouseMembers < HouseMembers
    # Initialise our parent class and set about scraping data from the web.
    def initialize(house_id)
      super

      @q_manager = QueueManager.new(house_id)

      retrieve_members_list
      assemble_members_data
    end

    private

    # Gets the list of house members. Depending on the circumstance, we either
    # just load a list from existing file or we got the parliament.uk site, and
    # scrape the list from there.
    #
    # In the case of loading the file, the errors processed will be merged into
    # the existing file data, and saved. This behaviour will continue until
    # there are no more errors to process.
    def retrieve_members_list
      if @q_manager.scrape_errors?
        load_file
      else
        scrape_members_list
      end
    end

    # Scrape a particular house's membership list from it's list page.
    def scrape_members_list
      url = (@house_id == Lords::HOUSE_ID) ? Lords::MEMBER_LIST_URL : Commons::MEMBER_LIST_URL
      log.info("Fetching '#{@house_id}' member list from #{url}")

      document = Nokogiri::HTML(open(url))
      pipeline = MemberListDocPipeline.new(@house_id, document)
      pipeline.house_member_list(@members)
    rescue => e
      log.info("Error retrieving '#{@house_id}' member list, URL #{member['url']}, Exception #{e.message}")
    end

    # Scrape more detailed house member's info from their specific page.
    def scrape_member_summary(member)
      log.info("Fetching (#{member['id']}) #{member['alphabetical_name']}")

      document = Nokogiri::HTML(open(member['url']))
      pipeline = MemberSummaryDocPipeline.new(@house_id, document)
      pipeline.enrich_member_data(member)

      member['timestamp'] = Time.now.strftime('%FT%T%:z')
    rescue => e
      log.info("Error processing '#{@house_id}' member ID #{member['id'].to_s}, URL #{member['url']}, Exception #{e.message}")
      @q_manager.error_queue.push(member['id'].to_s)
    end

    # Trigger scraping of more detailed house member information and save the
    # results to file.
    def assemble_members_data
      @q_manager.enqueue(@members)

      process_members_list { |member|
        scrape_member_summary(member)
      }

      save_file

      if @q_manager.error_queue_size > 0
        log.info("#{@q_manager.error_queue.length} entries in the error queue to reprocess")
      end
    end

    # Process the house members list, to retrieve more info about each member.
    # Splits the work across multiple threads, to diminish the time taken.
    def process_members_list
      threads = []

      @config[:scrape_no_of_threads].times do
        threads << Thread.new do
          until @q_manager.main_queue.empty?
            id = @q_manager.main_queue.pop

            if id
              member = @members.find { |item|
                item['id'] == id.to_i
              }

              yield member

              sleep(@config[:scrape_request_delay])
            end
          end
        end
      end

      threads.each { |t| t.join }
    end
  end
end