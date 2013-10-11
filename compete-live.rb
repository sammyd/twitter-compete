require 'rubygems'
require 'bundler/setup'

require 'json'
require 'twitter'

module TwitterCompete

    class RetweetStreamer
        def initialize(tweet_ids, secrets_path)
            @tweet_ids = tweet_ids
            @restClient = Twitter::REST::Client.new do |config|
                configure_twitter(config, secrets_path)
            end
            @streamingClient = Twitter::Streaming::Client.new do |config|
                configure_twitter(config, secrets_path)
            end
            @callbacks = []
            @retweetSum = 0
            start
        end

        def subscribe(&callback)
            @callbacks << callback
        end

        def collectInitialData
            # Find the current retweet count
            @competitionTweets = []
            @tweet_ids.each do |tweet_id|
                @competitionTweets << restClient.status(tweet_id)
            end
            @retweetSum = 0
            @competitionTweets.each { |t| @retweetSum += t.retweet_count.to_i }
        end

        def start
            collectInitialData
            streamingClient.user do |status|
                if status.retweet? and @competitionTweets.include? status.retweeted_status
                    @retweetSum += 1
                    @callbacks.each { |cb| cb.call(status) }
                end
            end
        end

        private
        def configure_twitter(config, secrets_path)
            secrets = JSON.parse ( IO.read(secrets_path) )
            secrets = secrets["twitter"]
            config.consumer_key         = secrets["consumer_key"]
            config.consumer_secret      = secrets["consumer_secret"]
            config.access_token         = secrets["access_token"]
            config.access_token_secret  = secrets["access_token_secret"]
        end
    end
end

