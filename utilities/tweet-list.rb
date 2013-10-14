require 'rubygems'
require 'bundler/setup'

require 'json'
require 'redis'

module TwitterCompete
    class TweetList
        attr_accessor :tweet_ids

        def initialize()
            @tweet_ids = Set.new
            if ENV.has_key?('REDISTOGO_URL')
                @redis = Redis.new(url: ENV['REDISTOGO_URL'])
            else
                @redis = Redis.new
            end
            @redis_key = "com.shinobicontrols.tweetcompete.tweet_ids"
            retrieve_list_from_store
        end

        def add_tweet(id)
            @tweet_ids << id
            persist_list_to_store
        end

        def remove_tweet(id)
            @tweet_ids.delete(id)
            persist_list_to_store
        end

        private
        def retrieve_list_from_store
            redis_string = @redis.get(@redis_key)
            if redis_string.nil?
                @tweet_ids = Set.new
            else
                @tweet_ids = JSON.parse(redis_string).to_set
            end
        end

        def persist_list_to_store
            @redis.set(@redis_key, @tweet_ids.to_a.to_json)
        end
    end
end