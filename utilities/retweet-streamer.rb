require 'rubygems'
require 'bundler/setup'

require 'json'
require 'twitter'

module TwitterCompete

    class RetweetStreamer
        attr_accessor :competitionTweets

        def initialize(tweet_list, secrets_path)
            @tweet_list = tweet_list
            @restClient = Twitter::REST::Client.new do |config|
                configure_twitter(config, secrets_path)
            end
            @user = @restClient.user
            @streamingClient = Twitter::Streaming::Client.new do |config|
                configure_twitter(config, secrets_path)
            end
            @callbacks = []
            @retweetSum = 0
            collectInitialData
        end

        def subscribe(&callback)
            @callbacks << callback
            # Send out the initial info
            message = { retweet_count: @retweetSum }
            callback.call(message)
        end

        def collectInitialData
            # Find the current retweet count
            @competitionTweets = []
            @tweet_list.tweet_ids.each do |tweet_id|
                @competitionTweets << @restClient.status(tweet_id)
            end
            @retweetSum = 0
            @competitionTweets.each { |t| @retweetSum += t.retweet_count.to_i }
            puts @retweetSum
        end

        def start
            @streamingClient.user do |status|
                if status.retweet? and @competitionTweets.include? status.retweeted_status
                    @retweetSum += 1
                    message = { retweet_count: @retweetSum,
                                tweet: {
                                    username: status.user.screen_name,
                                    text: status.text,
                                    tweet_time: status.created_at
                                }
                              }
                    puts message
                    @callbacks.each { |cb| cb.call(message) }
                end
            end
        end

        def current_stats
            message = { retweet_count: @retweetSum,
                        follower_count: @user.followers_count }
        end

        def add_tweet(tweet_id)
            @tweet_list.add_tweet(tweet_id)
            new_tweet = @restClient.status(tweet_id)
            @retweetSum += new_tweet.retweet_count.to_i
            @competitionTweets << new_tweet
        end

        def remove_tweet(tweet_id)
            @tweet_list.remove_tweet(tweet_id)
            tweet = @restClient.status(tweet_id)
            @retweetSum -= tweet.retweet_count.to_i
            @competitionTweets.delete tweet
        end

        private
        def configure_twitter(config, secrets_path)
            if(File.exists?(secrets_path))
                secrets = JSON.parse ( IO.read(secrets_path) )
                secrets = secrets["twitter"]
                config.consumer_key         = secrets["consumer_key"]
                config.consumer_secret      = secrets["consumer_secret"]
                config.access_token         = secrets["access_token"]
                config.access_token_secret  = secrets["access_token_secret"]
            else
                config.consumer_key         = ENV['TWITTER_CONSUMER_KEY']
                config.consumer_secret      = ENV['TWITTER_CONSUMER_SECRET']
                config.access_token         = ENV['TWITTER_ACCESS_TOKEN']
                config.access_token_secret  = ENV['TWITTER_ACCESS_TOKEN_SECRET']
            end
        end
    end
end

