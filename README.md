## Treasure Data and Sidekiq awesomeness

###Concept
Treasure data jobs take sometime to finish, and in most scenarios waiting is not really an option. 

Td-querier will create a Sidekiq job with the job_id of your Treasure Data Queries and will check if the job has finished.

If it is finished, it will send a callback to continue your data process.

If not it will reschedule itself until the job is done.

###Installation
    $ gem install td-querier

###Usage
```
querier = Querier.new("TREASURE_DATA_API_KEY")
database_name = 'my_td_database_name'
query_text = 'select count(*) from my_table'
options = {:klass=>"MyClass", :method=>"my_method", :results => "true"} #See Options section for this one

#Optional
on_demand_path = 'mysql://user:password@host/database/table' #will insert the result of your query into another table
priority = 1 #default 1
reschedule_time #Time interval for checking if the job is finished

querier.query(database_name, query_text, options, on_demand_path, priority, reschedule_time)
```

###Options
Once the job has finished sidekiq will stop retriying and will send a callback to a class method specified on the options.

* klass: The name of the class you want to use, i.e. "MyClass"
* method: The name of the class method you want to use, i.e. "my_method"
* results: if is "true" will fetch the results from treasure data and it will pass those results to your method as a parameter. Be aware that exceptionally large results might impact your performance.

###Internals
Querier objects are designed to query treasure data api asynchronously. 

This gem uses [Sidekiq] (https://github.com/mperham/sidekiq) so make sure your app plays nice with that.

Also it uses [td gem](https://rubygems.org/gems/td)

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

