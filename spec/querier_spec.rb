require 'spec_helper'

describe Querier do
  describe "Send the query to treasaure data" do
    context "Object initializacion" do
      it "will create a querier object given an api key string"
    end

    context "Wrong parameters" do
      it "will send a query to treasure data given that the key string and the rest of the params are correct"

      it "will raise an error if the api key is not valid"

      it "will raise an error if the database name is not valid"

      it "will raise an error if the query is not valid"
    end

    context "Right parameters" do
      it "will send a query to treasure data and instance a sidekiq job with the job id of the new job"
    end
  end

  describe "Sidekiq processing" do
    context "Standar processing" do
      it "will reschedule the sidekiq job if the treasure data job is not yet finished"

      it "will make a call to a given class method if que job is finished"
    end

    context "Error case" do
      it "will raise an exception if something explodes within sidekiq"
    end
  end
end
