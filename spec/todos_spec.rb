require "spec_helper"

describe Api::Application do
  let(:redis) { Redis.new(url: ENV["REDIS_URL"]) }

  context "GET /lists/1234/todos" do
    it "should be ok" do
      get "/lists/1234/todos"

      expect(last_response.status).to eq 200
    end

    it "should return its items" do
      redis.set("list-1234", %[[1, 2]])
      redis.set("todo-1", JSON.dump(uuid: 1, description: "item#1", done: false))
      redis.set("todo-2", JSON.dump(uuid: 2, description: "item#2", done: true))

      get "/lists/1234/todos"

      expect(JSON.parse(last_response.body)).to match_array([
        { "uuid" => 1, "description" => "item#1", "done" => false },
        { "uuid" => 2, "description" => "item#2", "done" => true },
      ])
    end

    it "should not return deleted items" do
      redis.set("list-1234", %[[10, 20]])
      redis.del("todo-10")
      redis.set("todo-20", JSON.dump(uuid: 20, description: "item#2", done: true))

      get "/lists/1234/todos"

      expect(JSON.parse(last_response.body)).to match_array([
        { "uuid" => 20, "description" => "item#2", "done" => true },
      ])
    end
  end

  context "PUT /lists/1234/todos/1" do
    it "should be able to update description" do
      redis.set("list-1234", %[[10]])
      redis.set("todo-10", JSON.dump("uuid" => 10, "description" => "Item#1", "done" => false))

      put "/lists/1234/todos/10", { description: "Item#2" }

      expect(last_response.status).to eq 200

      expect(JSON.parse(redis.get("todo-10"))).to eq(
        { "uuid" => "10", "description" => "Item#2", "done" => false },
      )
    end

    it "should be able to update done" do
      redis.set("list-1234", %[[11]])
      redis.set("todo-11", JSON.dump("uuid" => 11, "description" => "Item#1", "done" => false))

      put "/lists/1234/todos/11", { done: true }

      expect(last_response.status).to eq 200

      expect(JSON.parse(redis.get("todo-11"))).to eq(
        { "uuid" => "11", "description" => "Item#1", "done" => true },
      )
    end
  end

  context "DELETE /lists/1234/todos/12" do
    it "should be able to update done" do
      redis.set("list-1234", %[[12]])
      redis.set("todo-12", JSON.dump("uuid" => 12, "description" => "Item#1", "done" => false))

      delete "/lists/1234/todos/12"

      expect(last_response.status).to eq 200

      expect(redis.exists("todo-12")).to eq false
    end
  end

  context "POST /lists/1234/todos" do
    it "should create if list does not exist" do
      redis.del("list-1234")
      redis.del("todo-3")

      post "/lists/1234/todos", { uuid: 3, description: "Item#1" }

      expect(last_response.status).to eq 200

      expect(redis.get("list-1234")).to eq %[[3]]
      expect(JSON.parse(redis.get("todo-3"))).to match_array(
        { "uuid" => 3, "description" => "Item#1", "done" => false },
      )
    end

    it "should create if list already exists but it is empty" do
      redis.set("list-1234", "[]")
      redis.del("todo-4")

      post "/lists/1234/todos", { uuid: 4, description: "Item#1" }

      expect(last_response.status).to eq 200

      expect(redis.get("list-1234")).to eq %[[4]]
      expect(JSON.parse(redis.get("todo-4"))).to match_array(
        { "uuid" => 4, "description" => "Item#1", "done" => false },
      )
    end

    it "should create if list already exists with one item" do
      redis.set("list-1234", %[[5]])
      redis.set("todo-5", JSON.dump("uuid" => 5, "description" => "Item#1", "done" => false))
      redis.del("todo-6")

      post "/lists/1234/todos", { uuid: 6, description: "Item#2" }

      expect(last_response.status).to eq 200

      expect(redis.get("list-1234")).to eq %[[5,6]]
      expect(JSON.parse(redis.get("todo-5"))).to eq(
        { "uuid" => 5, "description" => "Item#1", "done" => false },
      )
      expect(JSON.parse(redis.get("todo-6"))).to eq(
        { "uuid" => 6, "description" => "Item#2", "done" => false },
      )
    end

    it "should be able to get the items" do
      redis.set("list-1234", %[[7]])
      redis.set("todo-7", JSON.dump("uuid" => 7, "description" => "Item#1", "done" => false))
      redis.del("todo-8")

      post "/lists/1234/todos", { "uuid" => 8, "description" => "Item#2", "done" => true }

      expect(last_response.status).to eq 200

      get "/lists/1234/todos"

      expect(JSON.parse(last_response.body)).to match_array([
        { "uuid" => 7, "description" => "Item#1", "done" => false },
        { "uuid" => 8, "description" => "Item#2", "done" => true },
      ])
    end
  end
end
