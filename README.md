# Treasure Data and Sidekiq awesomeness

##Installation

    $ gem install td-querier

##Usage
querier = Querier.new("TREASURE_DATA_API_KEY")
querier.query(database_name, query_text, on_demand_path, options, priority, reschedule_time) 
##Options

{
    :klass=>"MyClass", 
    :method=>"my_method", 
    :results => "true"
}

##Internals
Querier objects are designed to query treasure data api asynchronously. This gem uses [Sidekiq] (https://github.com/mperham/sidekiq) to achieve that.
