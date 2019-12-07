require "sinatra/json"

module Api
  class Application < Sinatra::Base
    helpers do
      def list_uuid(params)
        "list-" + params.fetch(:list_uuid, params["list_uuid"])
      end
    end

    configure do
      enable :cross_origin
      set :redis, Redis.new(url: ENV["REDIS_URL"])
    end

    before do
      response.headers["Access-Control-Allow-Origin"] = "*"
    end

    options "*" do
      response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
      response.headers["Access-Control-Allow-Methods"] = "GET, PUT, POST, DELETE, OPTIONS"
      response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept"
      response.headers["Access-Control-Allow-Origin"] = "*"
      200
    end

    get "/" do
      "api"
    end

    get "/lists/:list_uuid/todos" do
      list = list_uuid(params)
      items = if settings.redis.exists(list)
                JSON.parse(settings.redis.get(list)).map do |item_uuid|
                  if settings.redis.exists("todo-#{item_uuid}")
                    JSON.parse(settings.redis.get("todo-#{item_uuid}"))
                  end
                end
              else
                []
              end

      json items.reject { |item| item.nil? }
    end

    put "/lists/:list_uuid/todos/:todo_uuid" do
      current = JSON.parse(settings.redis.get("todo-#{params[:todo_uuid]}"))

      item = {
        uuid: params[:todo_uuid],
        description: params.fetch(:description) { current["description"] },
        done: !!params.fetch(:done) { current["done"] },
      }

      settings.redis.set("todo-#{item[:uuid]}", JSON.dump(item))
    end

    delete "/lists/:list_uuid/todos/:todo_uuid" do
      list = list_uuid(params)
      todo_uuids = if settings.redis.exists(list)
                     JSON.parse(settings.redis.get(list)) - [params[:todo_uuid]]
                   else
                     []
                   end

      settings.redis.del("todo-#{params[:todo_uuid]}")
      settings.redis.set(list, todo_uuids)
    end

    post "/lists/:list_uuid/todos" do
      list = list_uuid(params)

      item = {
        uuid: params[:uuid],
        description: params[:description],
        done: !!params.fetch(:done) { false },
      }

      todo_uuids = if settings.redis.exists(list)
                     JSON.parse(settings.redis.get(list)) << item[:uuid]
                   else
                     [item[:uuid]]
                   end

      settings.redis.set(list, JSON.dump(todo_uuids))
      settings.redis.set("todo-#{item[:uuid]}", JSON.dump(item))

      items = todo_uuids.map do |item_uuid|
                JSON.parse(settings.redis.get("todo-#{item_uuid}"))
              end

      json items
    end
  end
end
