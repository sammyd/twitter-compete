require 'faye/websocket'
require_relative '../utilities/retweet-streamer'
require_relative '../utilities/tweet-list'

COMPETITION_TWEETS=[388653721640767488, 387930173481701376, 388331507225743360,
    387519699548127232, 387240835643097088, 386146014543224833, 385664639218229248,
    385298574172766209, 383193303334027264, 382845281341280256, 382457879393214464,
    382130489626472448, 381391103250812928, 381004537131446272, 380599178604584960]


module TwitterCompete
    class CompetitionBackend
        KEEPALIVE_TIME = 15

        def initialize(app)
            @app     = app
            @clients = []
            @streamer = RetweetStreamer.new(TweetList.new, "secrets.json")
            @streamer.subscribe do |on|
                @clients.each do |ws|
                    ws.send(on.to_json)
                end
            end

            Thread.new do
                @streamer.start
            end
        end

        def call(env)
            if Faye::WebSocket.websocket?(env)
                # Websockets logic
                ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })

                ws.on :open do |event|
                    p [:open, ws.object_id]
                    @clients << ws
                    puts @streamer.current_stats
                    ws.send(@streamer.current_stats.to_json)
                end

                ws.on :message do |event|
                    p [:meesage, ws.object_id]
                    ws.send(@streamer.current_stats.to_json)
                end

                ws.on :close do |event|
                    p [:close, ws.object_id, event.code, event.reason]
                    @clients.delete(ws)
                    ws = nil
                end

                # Return async Rack response
                ws.rack_response
            else
                # Other call type
                env[:tweet_streamer] = @streamer 
                @app.call(env)
            end
        end
    end
end