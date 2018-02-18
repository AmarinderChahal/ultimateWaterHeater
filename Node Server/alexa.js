var alexa = require('alexa-app'),
    https = require('https'),
    http = require('http'),
    fs    = require('fs'),
    path  = require('path'),
    express = require('express');

var app = new alexa.app("youtube");
exapp = express();


var temperature = "";
var heatOn = false;
var manOn = false;


exapp.get('/', function(req, res) {
  res.sendFile(path.join(__dirname, 'index.html'));
});
exapp.get('/toggleman', function(req, res) {
  http.get('http://localhost:8000/togmanual', function(res){
    var body = "";
    res.on("data", data=>{
      body+=data;
    });
    res.on("end", ()=>{
      manOn = body=="true";
    });
  }, error=>{
    console.log('Java endpoint not up');
  });
  res.send(!manOn);
});

server = http.createServer(exapp);
server.listen(3000);

var preDebug = function(req, res){
  console.log("Alexa Called");
}

app.express({
    expressApp: exapp,
    endpoint: '/alexa',
    preRequest: preDebug
  });

app.intent("CommandIntent", {
    "slots": {"command": "LITERAL" },
    "utterances": [""]
  }, function(req, res){
    console.log('Received Command: '+req.slot("command"));
    command = req.slot("command");
    switch(command){
      case 'what the temperature is':
        res.say("The current temperature in the shower head is "+temperature.split('.')[0]+" degrees farenheit.");
        break;
      case 'turn on the heat':
        if(heatOn){
          res.say("The shower head is already on.");
          break;
        }
        res.say("The shower head has been turned on.");
        http.get('http://localhost:8000/togheat', function(res){
          var body = "";
          res.on("data", data=>{
            body+=data;
          });
          res.on("end", ()=>{
            heatOn = body=="true";
          });
        }, error=>{
          console.log('Java endpoint not up');
        })
        break;
      case 'turn off the heat':
        if(!heatOn){
          res.say("The shower head is already off.");
          break;
        }
        res.say("The shower head has been turned off.");
        http.get('http://localhost:8000/togheat', function(res){
          var body = "";
          res.on("data", data=>{
            body+=data;
          });
          res.on("end", ()=>{
            heatOn = body=="true";
          });
        }, error=>{
          console.log('Java endpoint not up');
        })
        break;
      default:
        console.log("Command | "+req.slot("command")+" | Not Found");
        res.say("I'm sorry, Shower does not understand this command");
    }
  });

setInterval(()=>{
  http.get('http://localhost:8000/temp', function(res){
    var body = "";
    res.on("data", data=>{
      body+=data;
    });
    res.on("end", ()=>{
      temperature = body;
    });
  }).on('error', error=>{
    console.log('Java endpoint not up')
  })
}, 1000);