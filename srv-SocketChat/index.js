var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var mysql      = require('mysql');
var connection = mysql.createConnection({
    host     : 'localhost',
    user     : 'ts_chat',
    password : '1234',
    database : 'ts_chat'
});

var userList = [];
var typingUsers = {};
var messages = [];

app.get('/', function(req, res){
  res.send('<h1>AppCoda - SocketChat Server</h1>');
});
/*
class DB {
    static sendRequest(_query) {
        var result = null;
        connection.connect();

        connection.query(_query, function (error, results, fields) {
            if (error) throw error;
            console.log(error,results);
            result = results;
            console.log('query[" ', _query, ' "]');
        });

        connection.end();

        console.log('result: ',result);

        return result;
    }

    static find(_name) {
        //console.log("name: ",_name);
        return this.sendRequest("SELECT * from `user` where name = '"+_name+"';");
    }

    static insert(_client_id,_name,_status) {
        return this.sendRequest("INSERT INTO `user` (`id`, `name`, `client_id`, `status`) VALUES (NULL, '"+_name+"', '"+_client_id+"', '"+_status+"');");
    }
}*/

// Get chat messages between 2 users
function getChat(clientNickname, recipientNickname) {
    var oldMessages = [];
    var messageInfo = {};

    for (var i=0; i < messages.length; i++){
        if ((messages[i]["clientNickname"] == clientNickname
            && messages[i]["recipientNickname"] == recipientNickname)
            || (messages[i]["clientNickname"] == recipientNickname
            && messages[i]["recipientNickname"] == clientNickname)) {

            messageInfo = {
                "clientNickname": messages[i]["clientNickname"],
                "recipientNickname": messages[i]["recipientNickname"],
                "message": messages[i]["message"],
                "date": messages[i]["date"],
            };

            oldMessages.push(messageInfo);
        }
    }

    return oldMessages;
}

http.listen(3000, function(){
    console.log('Listening on *:3000');
    //DB.sendRequest("SELECT * from `user` where name = '123';");
    //DB.find("ydo");
});


io.on('connection', function(clientSocket){
  console.log('a user connected');

  clientSocket.on('disconnect', function(){
    console.log('user disconnected');

    var clientNickname;
    for (var i=0; i<userList.length; i++) {
      if (userList[i]["id"] == clientSocket.id) {
        userList[i]["isConnected"] = false;
        clientNickname = userList[i]["nickname"];
        console.log("disconected ",clientNickname);
        break;
      }
    }

    delete typingUsers[clientNickname];
    io.emit("userList", userList);
    /*io.emit("userExitUpdate", clientNickname);
    io.emit("userTypingUpdate", typingUsers);*/
  });


  clientSocket.on("exitUser", function(clientNickname){
    console.log("exit - ", clientNickname, " ", clientSocket.id);


      for (var i=0; i<userList.length; i++) {
      if (userList[i]["nickname"] == clientNickname) {
        userList[i]["isConnected"] = false;
          //userList.splice(i, 1);
        break;
      }
    }
      console.log(userList);
      io.emit("userList", userList);
    //io.emit("userExitUpdate", clientNickname);
  });


  clientSocket.on("chatMessage", function(clientNickname, message, recipientNickname){

      console.log(clientNickname, ": `", message, "` to: ", recipientNickname)

      var currentDateTime = new Date().toLocaleString();

      //delete typingUsers[clientNickname];
      //io.emit("userTypingUpdate", typingUsers);

      var messageInfo = {};

      messageInfo["clientNickname"] = clientNickname;
      messageInfo["message"] = message;
      messageInfo["recipientNickname"] = recipientNickname;
      messageInfo["date"] = currentDateTime;

      messages.push(messageInfo);

      var client;
      var recipient;

      for (var i=0; i<userList.length; i++) {
          if (userList[i]["nickname"] == clientNickname) {
              client = userList[i];
          }
          if (userList[i]["nickname"] == recipientNickname) {
              recipient = userList[i];
          }
      }

      clientSocket.emit("loadChat", getChat(clientNickname,recipientNickname));

      if (clientNickname != recipientNickname && recipient["isConnected"]) {
          console.log("newCHatMsg send to re: ",recipient);
       //   io.to(recipient["id"]).emit('loadChat', getChat(clientNickname,recipientNickname));
        //  console.log(messageInfo);
          io.to(recipient["id"]).emit('newChatMessage', [messageInfo]);
      }
  });


  clientSocket.on("getChat", function (clientNickanme, recipientNickname) {
      oldMessages = getChat(clientNickanme, recipientNickname);
      console.log("loadChat: ", oldMessages);

      clientSocket.emit("loadChat", oldMessages);
  });


  clientSocket.on("connectUser", function(clientNickname) {
      var message = "User " + clientNickname + " was connected.";
      console.log(message);

      var userInfo = {};
      var foundUser = false;
      for (var i=0; i<userList.length; i++) {
        if (userList[i]["nickname"] == clientNickname) {
          userList[i]["isConnected"] = true
          userList[i]["id"] = clientSocket.id;
          userInfo = userList[i];
          foundUser = true;
          break;
        }
      }

      if (!foundUser) {
        userInfo["id"] = clientSocket.id;
        userInfo["nickname"] = clientNickname;
        userInfo["isConnected"] = true
        userList.push(userInfo);
      }

      console.log(userList);

      io.emit("userList", userList);
      //io.emit("userConnectUpdate", userInfo);
  });

/*
  clientSocket.on("startType", function(clientNickname){
    console.log("User " + clientNickname + " is writing a message...");
    typingUsers[clientNickname] = 1;
    io.emit("userTypingUpdate", typingUsers);
  });


  clientSocket.on("stopType", function(clientNickname){
    console.log("User " + clientNickname + " has stopped writing a message...");
    delete typingUsers[clientNickname];
    io.emit("userTypingUpdate", typingUsers);
  });
*/
});
