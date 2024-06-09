import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants.dart';
import 'package:flutter_chat_app/widgets/bottom_chat_field.dart';
import 'package:flutter_chat_app/widgets/chat_app_bar.dart';
import 'package:flutter_chat_app/widgets/chat_list.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    //get the arguments passed from previous screen
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    //get the contact uid from the arguments
    final contactUID = arguments[Constants.contactUID];
    //get the contact name from the arguments
    final contactName = arguments[Constants.contactName];
    //get the contact image from the arguments
    final contactImage = arguments[Constants.contactImage];
    //get the group id from the arguments
    final groupId = arguments[Constants.groupId];
    //check if the group id is empty - then it is a chat with a friend else it is a group chat
    final isGroupChat = groupId.isNotEmpty ? true : false;

    return Scaffold(
      appBar: AppBar(title: ChatAppBar(contactUID: contactUID)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(child: ChatList(contactUID: contactUID, groupId: groupId)),
            BottomChatField(
                contactUID: contactUID,
                contactName: contactName,
                contactImage: contactImage,
                groupId: groupId),
          ],
        ),
      ),
    );
  }
}
