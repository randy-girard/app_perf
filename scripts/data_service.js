const fs = require('fs');
const Tail = require('always-tail');
const net = require('net');
const request = require('request');

const logfile = process.argv[2];
console.log(logfile);

function sendHTTP(json) {
    var options = {
        uri: "http://localhost:5000/api/listener/2/19509de2-d07d-470f-a8f5-aab940569d8",
        method: 'POST',
        json: json
    };
    request(options, function (error, response, body) {
      if (!error && response.statusCode == 200) {
        //console.log(response); // Print the shortened url.
      }
    });
}

function convertNginx(line) {
    var parts = line.split("|");

    var requestID = parts[0];
    var start = parseFloat(parts[1]);
    var duration = parseFloat(parts[2]);
    var url = parts[6];

    var item = null;

    if(requestID)
      var data = {
        url: url
      }
      item = ["nginx", requestID, start - duration, duration * 1000, JSON.stringify(data)]

    return item;
}

var tail = new Tail(logfile, '\n');
var events = [];
var startTime = new Date();
tail.on('line', function(parseJson) {
  var currentTime = new Date();
  item = convertNginx(parseJson);
  if(item) {
   events.push(item);
  }

  dispatchTime = new Date(startTime.getTime() + (1000 * 10));
  if(events.length && currentTime >= dispatchTime) {
    console.log("Dispatching " + events.length + " events.");
    var json = {
      "name": "App Perf",
      "host": "127.0.0.1",
      "data": events
    };
    events = [];
    startTime = new Date();
    sendHTTP(json);
  }
});

tail.on('error', function(data) {
  console.log("error:", data);
});

tail.watch();
