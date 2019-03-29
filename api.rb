require "sinatra/json"

module Api
  class << self
    def redis
      @@redis
    end

    def redis=(server)
      @@redis = if server.is_a?(String)
                  uri = URI.parse(server)
                  Redis.new(host: uri.host, port: uri.port, password: uri.password)
                else
                  server
                end
    end
  end

  class Application < Sinatra::Base
    get "/" do
      json( {
        mykey: Api.redis.get("mykey"),
      })
    end
  end
end
