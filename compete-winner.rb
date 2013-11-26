require 'rubygems'
require 'bundler/setup'

require 'json'
require 'twitter'

TWEET_IDS = [391199389881880577, 391389246163939328, 391474701819600896,
             392235229017939968, 392301255227215872, 392924162739941376,
             392995830375776257, 393022685275783168, 396180296107712512,
             391251728706072576, 391285146139107328, 391284864907223040,
             391301814718836736, 392638743066468353]

def configure_twitter(config)
    secrets = JSON.parse ( IO.read("secrets.json") )
    secrets = secrets["twitter"]
    config.consumer_key         = secrets["consumer_key"]
    config.consumer_secret      = secrets["consumer_secret"]
    config.oauth_token          = secrets["access_token"]
    config.oauth_token_secret   = secrets["access_token_secret"]
end

def rate_limited_request
    num_attempts = 0
    begin
        num_attempts += 1
        yield
    rescue Twitter::Error::TooManyRequests => error
        if num_attempts % 3 == 0
            puts "Hit twitter's rate limit. Waiting a minute... (#{num_attempts} attempts)"
            sleep (60)
            retry
        else
            retry
        end
    end
end

@client = Twitter::REST::Client.new do |config|
    configure_twitter(config)
end

# Find all the people that retweeted the correct tweets
@retweeters = Set.new
TWEET_IDS.each do |tweet_id|
    rts = rate_limited_request do
        @client.retweeters_ids(tweet_id).to_a
    end
    @retweeters.merge rts
end

# People who used the hashtag
@hashtags = rate_limited_request do
    @client.search("#shinobigiveaway", :count => 100)
end
@hashtag_users = @hashtags.map { |t| t.user.id }

# Get a full list of followers
@followers = rate_limited_request do
    @client.follower_ids("shinobicontrols")
end

# The intersection gives the total number of competition entrants
@entrants = (@retweeters | @hashtag_users) & @followers

# Get a list of 10 winners
@winner_ids = @entrants.to_a.sample(20)
@winners = []
@winner_ids.each do |winner_id|
    user = rate_limited_request do
        @client.user(winner_id)
    end
    @winners << user
end

puts "Total retweeters: #{@retweeters.count}"
puts "Total hashtaggers: #{@hashtag_users.count}"
puts "Total followers: #{@followers.count}"
puts "Total entrants: #{@entrants.count}"
puts "Winners: #{@winners.map { |w| w.screen_name }}"
