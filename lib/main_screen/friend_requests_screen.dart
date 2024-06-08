import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants.dart';
import 'package:flutter_chat_app/widgets/app_bar_back_button.dart';
import 'package:flutter_chat_app/widgets/friends_list.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text('Friend Requests'),
      ),
      body: Column(
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
          const Expanded(
              child: FriendsList(viewType: FriendViewType.friendRequests)),
        ],
      ),
    );
  }
}
