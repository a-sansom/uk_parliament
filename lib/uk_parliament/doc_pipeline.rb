module UkParliament
  # Class defining the pipeline process for a scraped document.
  class DocPipeline
    include UkParliament

    # Initialise the class instance variables.
    def initialize(house_id, document)
      @house_id = house_id
      @document = document

      define_commons_tasks
      define_lords_tasks
    end

    private

    # Define the tasks that will be performed for a commons pipeline.
    def define_commons_tasks
      @commons_tasks = []
    end

    # Define the tasks that will be performed for a lords pipeline.
    def define_lords_tasks
      @lords_tasks = []
    end

    protected

    # Execute the relevant pipeline's tasks.
    def execute
      # TODO We can do this better.
      if @house_id == Commons::HOUSE_ID
        @commons_tasks.each { |function_name|
          send(function_name)
        }
      elsif @house_id == Lords::HOUSE_ID
        @lords_tasks.each { |function_name|
          send(function_name)
        }
      end
    end
  end

end