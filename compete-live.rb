require 'rubygems'
require 'bundler/setup'

require 'json'
require 'tweetstream'


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

TweetStream::Client.new.sample do |status|
    puts "#{status.text}"
end