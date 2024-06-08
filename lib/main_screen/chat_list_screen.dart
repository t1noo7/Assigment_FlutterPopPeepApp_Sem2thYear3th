import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants.dart';
import 'package:flutter_chat_app/models/last_message_model.dart';
import 'package:flutter_chat_app/providers/authentication_provider.dart';
import 'package:flutter_chat_app/providers/chat_provider.dart';
import 'package:provider/provider.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            //Cupertinosearchbar
            CupertinoSearchTextField(
              placeholder: 'Search',
              style: const TextStyle(
                color: Colors.white,
              ),
              onChanged: (value) {
                print(value);
              },
            ),
            Expanded(
              child: StreamBuilder<List<LastMessageModel>>(
                  stream: context.read<ChatProvider>().getChatListStream(uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Something went wrong'),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasData) {
                      final chatList = snapshot.data!;
                      return ListView.builder(
                        itemCount: chatList.length,
                        itemBuilder: (context, index) {
                          final chat = chatList[index];
                          final dateTime =
                              formatDate(chat.timeSent, [hh, ':', nn, ' ', am]);
                          //check if we sent the last message
                          final isMe = chat.senderUID == uid;
                          //dis the last message correctly
                          final lastMessage =
                              isMe ? 'You: ${chat.message}' : chat.message;
                          return ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    NetworkImage(chat.contactImage),
                              ),
                              title: Text(chat.contactName),
                              subtitle: Text(lastMessage,
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              trailing: Text(dateTime),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, Constants.chatScreen,
                                    arguments: {
                                      Constants.contactUID: chat.contactUID,
                                      Constants.contactName: chat.contactName,
                                      Constants.contactImage: chat.contactImage,
                                      Constants.groupId: ''
                                    });
                              });
                        },
                      );
                    }
                    return const Center(
                      child: Text('No chats yet'),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
