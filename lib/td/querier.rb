# -*- coding: utf-8 -*-
require 'td'
require 'td-client'
require 'sidekiq'

class Querier
  include Sidekiq::Worker

  def initialize(api_key="")
    @api_key = api_key
  end

  def query(database, query, opts)
    on_demand_path = (opts && opts['on_demand_path'] != nil && opts['on_demand_path'] != '') ? opts['on_demand_path'] : ''
    priority = (opts && opts['priority'] != nil && opts['priority'] != '') ? opts['priority'] : 1
    reschedule_time = (opts && opts['reschedule_time'] != nil && opts['reschedule_time'] != '') ? opts['reschedule_time'] : 300

    client = TreasureData::Client.new(@api_key)
    job = client.query(database, query, on_demand_path, priority)
    Querier.perform_async(@api_key, job.job_id, opts)
  end

  def perform(api_key, job_id, opts)
    begin
      client = TreasureData::Client.new(api_key)
      job = client.job(job_id)
      #reschedule if the job is not finished
      unless job.finished?
        reschedule_time = (opts && opts['reschedule_time'] != nil && opts['reschedule_time'] != '') ? opts['reschedule_time'].to_i : 300
        return Querier.perform_in(reschedule_time, api_key, job_id, opts)
      end
    rescue TreasureData::APIError e
      puts e.message
      return false
    end

    if opts
      stringified_opts = Hash[opts.map{ |k, v| [k.to_s, v] }]
      klass = stringified_opts['klass']
      meth = stringified_opts['method']
      send_results = stringified_opts['results']
      results = (send_results.to_s == "true" ? job.result : nil)
      eval(klass).send(meth.to_s, results)
    end
  end
end
