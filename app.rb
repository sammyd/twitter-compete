require 'sinatra/base'

module TwitterCompete
    class App < Sinatra::Base
        get "/" do
            erb :"index.html"
        end
    end
end