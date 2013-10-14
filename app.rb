require 'sinatra/base'

module TwitterCompete
    class App < Sinatra::Base
        enable :logging

        get "/" do
            @tweet_count = streamer.competitionTweets.count
            haml :"index.html"
        end

        # Manage the list of tweets
        get "/tweets" do
            @tweet_list = streamer.competitionTweets
            haml :"tweets.html"
        end

        post "/tweets" do
            streamer.add_tweet params[:tweet_id]
            redirect to('/tweets')
        end

        get "/tweets/delete/:tweet_id" do
            streamer.remove_tweet params[:tweet_id]
            redirect to('/tweets')
        end

        private
        def streamer
            env[:tweet_streamer]
        end
    end
end