require "./spec_helper"

describe Trefoil::Client do
  response_body = "foo"
  WebMock.stub(:get, "https://a.4cdn.org/test").to_return(status: 200, body: response_body)

  describe "#get" do
    it "makes requests" do
      client = Trefoil::Client.new
      client.get("test").should eq response_body
    end

    it "removes leading `/` in requests" do
      client = Trefoil::Client.new
      client_2 = Trefoil::Client.new
      client.get("//test").should eq client_2.get("test")
    end

    it "limits requests to 1 per second" do
      client = Trefoil::Client.new
      time_before = Time.now
      client.get("/test")
      client.get("/test")
      Time.now.should be >= (time_before + 1.second)
    end
  end

  describe "#get?" do
    it "returns nil instead of blocking when we're rate limited" do
      client = Trefoil::Client.new

      client.get?("/test").should eq response_body
      client.get?("/test").should be_nil
    end
  end

  describe "#rate_limited?" do
    it "returns truthy when we are limited" do
      client = Trefoil::Client.new
      client.get("/test")
      client.rate_limited?.should be_true
    end

    it "returns falsy when we are not limited" do
      client = Trefoil::Client.new
      client.rate_limited?.should be_false
    end
  end

  WebMock.reset
end
