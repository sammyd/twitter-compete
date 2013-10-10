require 'rubygems'
require 'bundler/setup'

require 'json'
require 'tweetstream'


USERNAME = "iwantmyrealname"
HASHTAG  = "#iOS7DayByDay"

def configure_twitter(config)
    secrets = JSON.parse ( IO.read("secrets.json") )
    secrets = secrets["twitter"]
    config.consumer_key         = secrets["consumer_key"]
    config.consumer_secret      = secrets["consumer_secret"]
    config.oauth_token          = secrets["access_token"]
    config.oauth_token_secret   = secrets["access_token_secret"]
    config.auth_method          = :oauth
end


TweetStream.configure do |config|
    configure_twitter(config)
end


# Get a client
client = TweetStream::Client.new
puts client.inspect

client.userstream do |status|
    
    if status.retweet?
        puts "IT'S A RETWEET"
        if status.retweeted_status.user.screen_name == USERNAME
            if status.retweeted_status.text.include? HASHTAG
                if status
                puts "It's a valid competition entry"
            end
        end
    end
end