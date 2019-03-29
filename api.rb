require "sinatra/json"

module Api
  class Application < Sinatra::Base
    helpers do
      def list_uuid(params)
        "list-" + params.fetch(:list_uuid, params["list_uuid"])
      end

      def redis
        @redis ||= Redis.new(url: ENV["REDIS_URL"])
      end
    end

    get "/" do
      "api"
    end

    get "/lists/:list_uuid/todos" do
      list = list_uuid(params)
      items = if redis.exists(list)
                JSON.parse(redis.get(list)).map do |item_uuid|
                  JSON.parse(redis.get("todo-#{item_uuid}"))
                end
              else
                []
              end

      json items
    end

    put "/lists/:list_uuid/todos/:todo_uuid" do
      current = JSON.parse(redis.get("todo-#{params[:todo_uuid]}"))

      item = {
        uuid: params[:todo_uuid].to_i,
        description: params.fetch(:description) { current["description"] },
        done: !!params.fetch(:done) { current["done"] },
      }

      redis.set("todo-#{item[:uuid]}", JSON.dump(item))
    end

    post "/lists/:list_uuid/todos" do
      list = list_uuid(params)

      item = {
        uuid: params[:uuid].to_i,
        description: params[:description],
        done: !!params.fetch(:done) { false },
      }

      todo_uuids = if redis.exists(list)
                     JSON.parse(redis.get(list)) << item[:uuid]
                   else
                     [item[:uuid]]
                   end

      redis.set(list, JSON.dump(todo_uuids))
      redis.set("todo-#{item[:uuid]}", JSON.dump(item))

      items = todo_uuids.map do |item_uuid|
                JSON.parse(redis.get("todo-#{item_uuid}"))
              end

      json items
    end
  end
end
