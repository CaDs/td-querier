# -*- coding: utf-8 -*-
require 'td'
require 'td-client'
require 'sidekiq'

class Querier
  include Sidekiq::Worker

  def initialize(api_key="")
    @api_key = api_key
  end

  def query(database, query, opts, on_demand_path='', priority=1, reschedule_time=300)
    client = TreasureData::Client.new(@api_key)
    job = client.query(database, query, on_demand_path, priority)
    Querier.perform_async(@api_key, job.job_id, opts, reschedule_time)
  end

  def perform(api_key, job_id, opts, reschedule_time=300)
    client = TreasureData::Client.new(api_key)
    job = client.job(job_id)
    #reschedule if the job is not finished
    return Querier.perform_in(reschedule_time, api_key, job_id, opts, reschedule_time) unless job.finished?

    if opts
      klass = opts[:klass]
      meth = opts[:method]
      send_results = opts[:results]
      results = (send_results.to_s == "true" ? job.results : nil)
      eval(klass).send(meth.to_s, results)
    end
  end
end