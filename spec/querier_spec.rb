require 'spec_helper'

describe Querier do
  describe "Send the query to treasaure data" do
    context "Wrong parameters" do

      it "will raise an error if the api key is not valid" do
        fake_client = Object.new
        fake_client.should_receive(:query).and_raise(TreasureData::APIError.new("apikey authentication failed"))
        TreasureData::Client.should_receive(:new).and_return(fake_client)
        Querier.should_not_receive(:perform_async)

        querier = Querier.new("bad_key")
        lambda{querier.query("database", "my_query", {})}.should raise_error(TreasureData::APIError)
      end

      it "will raise an error if the database name is not valid" do
        fake_client = Object.new
        fake_client.should_receive(:query).and_raise(TreasureData::NotFoundError.new("Couldn't find UserDatabase with name = bad_name"))
        TreasureData::Client.should_receive(:new).and_return(fake_client)
        Querier.should_not_receive(:perform_async)

        querier = Querier.new("good_key")
        lambda{querier.query("bad_name", "my_query", {})}.should raise_error(TreasureData::NotFoundError)
      end
    end

    context "Right parameters" do
      it "will send a query to treasure data and instance a sidekiq job with the job id of the new job" do
        fake_job = Object.new
        fake_job.should_receive(:job_id).and_return(1)

        fake_client = Object.new
        fake_client.should_receive(:query).and_return(fake_job)

        TreasureData::Client.should_receive(:new).and_return(fake_client)

        Querier.should_receive(:perform_async).and_return(true)

        querier = Querier.new("good_key")
        querier.query("database", "my_query", {})
      end
    end
  end

  describe "Sidekiq processing" do
    context "Standar processing" do
      before(:each) do
        @opts = {:klass => "Object", :method => "fake_method", :results => "false"}
        @fake_job = Object.new
        @fake_client = Object.new
        @fake_client.should_receive(:job).and_return(@fake_job)
        TreasureData::Client.should_receive(:new).and_return(@fake_client)
      end

      it "will reschedule the sidekiq job if the treasure data job is not yet finished" do
        @fake_job.should_receive(:finished?).and_return(false)
        Querier.should_receive(:perform_in).with(300, "apikey", 1, @opts, 300).and_return(true)
        Querier.new.perform("apikey", 1, @opts)
      end

      it "will make a call to a given class method if que job is finished" do
        @fake_job.should_receive(:finished?).and_return(true)
        Object.should_receive(:fake_method).and_return(true)
        Querier.new.perform("apikey", 1, @opts)
      end

      it "will request the query results if the options for result are set to true" do
        new_opts = {:klass => "Object", :method => "fake_method", :results => "true"}
        results = [[1]]
        @fake_job.should_receive(:finished?).and_return(true)
        @fake_job.should_receive(:results).and_return(results)
        Object.should_receive(:fake_method).and_return(true)
        Querier.new.perform("apikey", 1, new_opts)
      end
    end

    context "Error case" do
      it "will raise an exception if something explodes within sidekiq" do
        @opts = {:klass => "Object", :method => "fake_method", :results => "false"}
        @fake_job = Object.new
        @fake_client = Object.new
        @fake_client.should_receive(:job).and_return(@fake_job)
        TreasureData::Client.should_receive(:new).and_return(@fake_client)

        @fake_job.should_receive(:finished?).and_raise(RuntimeError.new("unexpected error"))
        lambda{Querier.new.perform("apikey", 1, @opts)}.should raise_error(RuntimeError)
      end
    end
  end
end
