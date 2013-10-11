$(function() {
    var scheme = "ws://";
    var uri    = scheme + window.document.location.host + "/";
    var ws     = new WebSocket(uri);

    ws.onmessage = function(message) {
        var data = JSON.parse(message.data)
        console.log(data)
        if('retweet_count' in data) {
            $("#retweet-count").text(data.retweet_count);
        }
        if('follower_count' in data) {
            $("#follower-count").text(data.follower_count);
        }
        if('tweet' in data) {
            $("#tweets").prepend("<div class='tweet'>" +
                "<div class='username'>" + data.tweet.username + "</div>" +
                "<div class='tweet-content'>" + data.tweet.text + "</div>" +
                "<div class='time'>" + data.tweet.tweet_time + "</div>" +
                "</div>");
        }
        if('follower' in data) {
            $("#followers").prepend("<div class='tweet'>" +
                "<div class='username'>" + data.tweet.username + "</div>" +
                "<div class='time'>" + data.tweet.follow_time + "</div>" +
                "</div>");
        }
    }
});