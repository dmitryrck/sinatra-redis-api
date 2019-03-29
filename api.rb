module Api
  class Application < Sinatra::Base
    get "/" do
      "api"
    end
  end
end
