import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_app/constants.dart';
import 'package:flutter_chat_app/widgets/app_bar_back_button.dart';
import 'package:flutter_chat_app/widgets/friends_list.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
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
        title: const Text('Friends'),
      ),
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
            const Expanded(
                child: FriendsList(viewType: FriendViewType.friends)),
          ],
        ),
      ),
    );
  }
}
