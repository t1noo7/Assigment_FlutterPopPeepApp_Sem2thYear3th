import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants.dart';
import 'package:flutter_chat_app/models/user_model.dart';
import 'package:flutter_chat_app/providers/authentication_provider.dart';
import 'package:flutter_chat_app/utilities/global_methods.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatAppBar extends StatefulWidget {
  const ChatAppBar({super.key, required this.contactUID});
  final String contactUID;

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context
          .read<AuthenticationProvider>()
          .userStream(userID: widget.contactUID),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userModel =
            UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

        return Row(
          children: [
            userImageWidget(
              imageUrl: userModel.image,
              radius: 20,
              onTap: () {
                // Navigate to this friends profile with uid as argument
                Navigator.pushNamed(context, Constants.profileScreen,
                    arguments: userModel.uid);
              },
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userModel.name, style: GoogleFonts.openSans(fontSize: 16)),
                Text(
                  'Online',
                  // userModel.isOnline ? 'Online' : 'Last seen ${GlobalMethods.formatTimestamp(userModel.lastSeen)}',
                  style: GoogleFonts.openSans(fontSize: 12),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
