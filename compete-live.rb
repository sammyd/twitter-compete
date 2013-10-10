require 'rubygems'
require 'bundler/setup'

require 'json'
require 'tweetstream'
require 'twitter'

TWEET_ID = 387930173481701376

def configure_twitter(config)
    secrets = JSON.parse ( IO.read("secrets.json") )
    secrets = secrets["twitter"]
    config.consumer_key         = secrets["consumer_key"]
    config.consumer_secret      = secrets["consumer_secret"]
    config.oauth_token          = secrets["access_token"]
    config.oauth_token_secret   = secrets["access_token_secret"]
end


# Configure the 2 required gems
TweetStream.configure do |config|
    configure_twitter(config)
    config.auth_method          = :oauth
end

Twitter.configure do |config|
    configure_twitter(config)
end

# Find the current retweet count
competitionTweet = Twitter.status(TWEET_ID)
retweetSum = competitionTweet.retweet_count.to_i

puts "Current retweet count: #{retweetSum}"


# Get a streaming client
client = TweetStream::Client.new

client.userstream do |status|
    puts status
    if status.retweet?
        if status.retweeted_status == competitionTweet
            retweetSum += 1
            puts "New competition entry (#{retweetSum})"
        end
    end
end