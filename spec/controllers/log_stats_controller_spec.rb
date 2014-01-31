require 'spec_helper'

describe LogStatsController do

  describe "GET 'systems'" do
    it "returns http success" do
      get 'systems'
      response.should be_success
    end
  end

  describe "GET 'stats'" do
    it "returns http success" do
      get 'stats'
      response.should be_success
    end
  end

end
