# -*- coding: utf-8 -*-
require 'td'
require 'td-client'
require 'sidekiq'

class Querier
  include Sidekiq::Worker

  def initialize(api_key="")
    @key = api_key
  end

  def query(database, query, redirect_to, opts, priority=1, reschedule_time=5.minutes)
    client = TreasureData::Client.new(@key)
    job = client.query(database, query, redirect_to, priority)
    Querier.perform_async(@key, job.job_id, opts, reschedule_time)
  end

  def perform(api_key, job_id, opts, reschedule_time=5.minutes)
    client = TreasureData::Client.new(api_key)
    job = client.job(job_id)
    #reschedule if the job is not finished
    return Querier.perform_in(reschedule_time, api_key, job_id, opts, reschedule_time) unless job.finished?

    if opts
      klass = opts['klass']
      meth = opts['meth']
      res = opts['results']
      results = (res == "true" ? job.results : nil)
      class_eval(klass).send(meth.to_s, results)
    end
  end
end