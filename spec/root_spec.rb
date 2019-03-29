require "spec_helper"

describe Api::Application do
  context "Get /" do
    it "should be ok" do
      get "/"

      expect(last_response.status).to eq 200
    end

    it "should return correct redis key" do
      Api.redis.set("mykey", "this value")

      get "/"

      expect(JSON.parse(last_response.body)).to eq("mykey" => "this value")
    end
  end
end
