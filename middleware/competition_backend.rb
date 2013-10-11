require 'faye/websocket'
require_relative '../compete-live'

module TwitterCompete
    class CompetitionBackend
        KEEPALIVE_TIME = 15

        def initialize(app)
            @app     = app
            @clients = []

            Thread.new do
                streamer = RetweetStreamer.new([387930173481701376], "secrets.json")
                streamer.subscribe do |on|
                    @clients.each do |ws|
                        puts "Sending #{on}"
                        ws.send(on.to_json)
                    end
                end
                streamer.start
            end
        end

        def call(env)
            if Faye::WebSocket.websocket?(env)
                # Websockets logic
                ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })

                ws.on :open do |event|
                    p [:open, ws.object_id]
                    @clients << ws
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
                @app.call(env)
            end
        end
    end
end