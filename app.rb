require 'sinatra/base'

module TwitterCompete
    class App < Sinatra::Base
        get "/" do
            haml :"index.html"
        end
    end
end