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
      items = redis.get(list)

      items
    end

    post "/lists/:list_uuid/todos" do
      list = list_uuid(params)
      description = params[:description]

      new_value = if redis.exists(list)
                    JSON.parse(redis.get(list)) << params[:description]
                  else
                    [params[:description]]
                  end

      redis.set(list, JSON.dump(new_value))

      redis.get(list)
    end
  end
end
