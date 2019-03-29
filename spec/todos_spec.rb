require "spec_helper"

describe Api::Application do
  let(:redis) { Redis.new(url: ENV["REDIS_URL"]) }

  context "GET /lists/1234/todos" do
    it "should be ok" do
      get "/lists/1234/todos"

      expect(last_response.status).to eq 200
    end

    it "should return its items" do
      redis.set("list-1234", %[["item#1", "item#2"]])

      get "/lists/1234/todos"

      expect(JSON.parse(last_response.body)).to eq ["item#1", "item#2"]
    end
  end

  context "POST /lists/1234/todos" do
    it "should create if list does not exist" do
      redis.del("list-1234")

      post "/lists/1234/todos", { description: "Item#1" }

      expect(last_response.status).to eq 200

      expect(redis.get("list-1234")).to eq %[["Item#1"]]
    end

    it "should create if list already exists but it is empty" do
      redis.set("list-1234", "[]")

      post "/lists/1234/todos", { description: "Item#1" }

      expect(last_response.status).to eq 200

      expect(redis.get("list-1234")).to eq %[["Item#1"]]
    end

    it "should create if list already exists with one item" do
      redis.set("list-1234", %[["Item#1"]])

      post "/lists/1234/todos", { description: "Item#2" }

      expect(last_response.status).to eq 200

      expect(redis.get("list-1234")).to eq %[["Item#1","Item#2"]]
    end

    it "should be able to get the items" do
      redis.set("list-1234", %[["Item#1"]])

      post "/lists/1234/todos", { description: "Item#2" }

      expect(last_response.status).to eq 200

      get "/lists/1234/todos"

      expect(JSON.parse(last_response.body)).to eq ["Item#1", "Item#2"]
    end
  end
end
