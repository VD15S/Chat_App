import 'dart:convert';

import 'package:chat_application/Models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'chat_controller.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController msgInputController = TextEditingController();
  Color purple = Color.fromARGB(255, 176, 119, 205);
  Color white = Color.fromARGB(255, 255, 255, 255);

  Color black = Colors.black;
  late IO.Socket socket;
  ChatController chatController = ChatController();
  @override
  // void initState() {
  //   // TODO: implement initState
  //   socket = IO.io(
  //       'https://localhost:4000',
  //       IO.OptionBuilder()
  //           .setTransports(['websocket'])
  //           .disableAutoConnect()
  //           .build());
  //   socket.connect();
  //   super.initState();
  // }
  void initState() {
    super.initState();
    connect();
  }

  void connect() {
    socket = IO.io("http://172.29.0.100:5000", <String, dynamic>{
      "transports": ["websocket"],
      "autoconnect": true,
    });
    socket.connect();
    socket.onConnect((data) => print("Connected"));
    print(socket.connected);
    setUpSocketListener();
  }

  void setUpSocketListener() {
    socket.on('message-receive', (data) {
      try {
        print("OnEventReceive: message-receive");
        print("OnEventReceive: $data");
        var dataAsJson = jsonDecode(data);
        Message msg = Message.fromJson(dataAsJson);
        chatController.chatMessages.add(msg);
      } on Exception catch (e) {
        print("OnEventReceive: $e");
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          backgroundColor: black,
          body: Container(
              child: Column(
            children: [
              Expanded(
                  child: Container(
                child: Text("Connected User"),
              )),
              Expanded(
                flex: 9,
                child: Obx(
                  () => ListView.builder(
                    itemCount: chatController.chatMessages.length,
                    itemBuilder: (context, index) {
                      var currentItem = chatController.chatMessages[index];
                      return MessageItem(
                        sentByMe: currentItem.sentByMe == socket.id,
                        message: currentItem.message,
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                  child: Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.purple,
                  controller: msgInputController,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10)),
                      suffixIcon: Container(
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        child: Container(
                          color: purple,
                          child: IconButton(
                            color: white,
                            onPressed: () {
                              sendMessage(msgInputController.text);
                              msgInputController.text = "";
                            },
                            icon: Icon(Icons.send),
                          ),
                        ),
                      )),
                ),
              ))
            ],
          ))),
    );
  }

  void sendMessage(String text) {
    var messageJson = {"message": text, "sentByMe": socket.id};
    socket.emit('message', messageJson);
    chatController.chatMessages.add(Message.fromJson(messageJson));
  }
}

class MessageItem extends StatelessWidget {
  MessageItem({super.key, required this.sentByMe, required this.message});
  Color purple = Color.fromARGB(255, 176, 119, 205);
  Color white = Color.fromARGB(255, 255, 255, 255);
  final bool sentByMe;
  final String message;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: sentByMe ? purple : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: TextStyle(color: sentByMe ? white : purple, fontSize: 18),
            ),
            Text(" 1:20 PM",
                style: TextStyle(
                    color: (sentByMe ? white : purple).withOpacity(0.7),
                    fontSize: 10))
          ],
        ),
      ),
    );
  }
}
