require 'filequeue'

module UkParliament
  # Class to create/manage a queue for a set of items that will be scraped.
  class QueueManager
    include UkParliament

    # Unique identifier for the main work queue.
    QUEUE_MAIN = 'main'
    # Unique identifier for the error queue.
    QUEUE_ERROR = 'error'

    # Instance data accessor(s).
    attr_reader :main_queue, :error_queue, :active_queue

    # Set up queue states.
    def initialize(name = 'commons')
      config = configuration
      main_queue_file_name = File.join(config[:queue_file_path], "#{name}.queue")
      error_queue_file_name = File.join(config[:queue_file_path], "#{name}.error.queue")

      @main_queue = FileQueue.new(main_queue_file_name)
      @error_queue = FileQueue.new(error_queue_file_name)

      reset_main_queue
      set_active_queue
    end

    # Identify if there were errors from the last scrape.
    def scrape_errors?
      if @active_queue == QUEUE_ERROR
        true
      else
        false
      end
    end

    # Return the current size of the error queue.
    #
    # This is a bit of a work around FileQueue.
    # https://github.com/pezra/filequeue/pull/4
    def error_queue_size
      size = 0

      if File.exists?(@error_queue.file_name)
        size = @error_queue.length
      end

      size
    end

    # Set up the queue, either with provided items, or from the error queue.
    def enqueue(members)
      if @active_queue == QUEUE_ERROR
        populate_from_error_queue
      else
        populate(members, 'id')
      end

      log.info("Populated queue with #{@main_queue.length} items...")
    end

    private

    # Empty the main queue for a house.
    def reset_main_queue
      if File.exists?(@main_queue.file_name)
        @main_queue.clear
      end
    end

    # Identify the currently active queue, main or error.
    def set_active_queue
      @active_queue = QUEUE_MAIN

      if File.exists?(@error_queue.file_name)
        unless @error_queue.empty?
          @active_queue = QUEUE_ERROR
        end
      end
    end

    # Populate the main queue.
    def populate(items, key)
      items.each { |member|
        @main_queue.push(member[key].to_s)
      }
    end

    # Populate the main queue with items from the error queue.
    def populate_from_error_queue
      log.info('Populating queue from error queue...')

      until @error_queue.empty?
        # Could prevent potentially a lot of disk IO by just overwriting the
        # file directly and clear() the error queue...
        id = @error_queue.pop
        @main_queue.push(id)
      end
    end

  end

end