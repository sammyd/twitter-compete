require 'rubygems'
require 'bundler/setup'

require 'json'
require 'twitter'

TWEET_ID = 387930173481701376

def configure_twitter(config)
    secrets = JSON.parse ( IO.read("secrets.json") )
    secrets = secrets["twitter"]
    config.consumer_key         = secrets["consumer_key"]
    config.consumer_secret      = secrets["consumer_secret"]
    config.access_token         = secrets["access_token"]
    config.access_token_secret  = secrets["access_token_secret"]
end


restClient = Twitter::REST::Client.new do |config|
    configure_twitter(config)
end

streamingClient = Twitter::Streaming::Client.new do |config|
    configure_twitter(config)
end

# Find the current retweet count
competitionTweet = restClient.status(TWEET_ID)
retweetSum = competitionTweet.retweet_count.to_i

puts "Current retweet count: #{retweetSum}"


streamingClient.user do |status|
    puts status
    if status.retweet?
        if status.retweeted_status == competitionTweet
            retweetSum += 1
            puts "New competition entry (#{retweetSum})"
        end
    end
end