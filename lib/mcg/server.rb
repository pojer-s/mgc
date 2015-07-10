require 'sinatra/base'

require 'json'
require 'net/http'

class MCG

    class Server < Sinatra::Base

        get "/callback" do
            settings.mcg.generate
            "ok"
        end

    end
end
