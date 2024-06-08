import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_app/constants.dart';
import 'package:flutter_chat_app/models/user_model.dart';
import 'package:flutter_chat_app/providers/authentication_provider.dart';
import 'package:flutter_chat_app/utilities/global_methods.dart';
import 'package:flutter_chat_app/widgets/app_bar_back_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;

    // Get user data from arguments
    final uid = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text('Profile'),
        actions: [
          if (currentUser.uid == uid)
            // Logout button
            IconButton(
              onPressed: () async {
                // Navigate to settings screen with uid as argument
                await Navigator.pushNamed(context, Constants.settingsScreen,
                    arguments: uid);
              },
              icon: const Icon(Icons.settings),
            ),
        ],
      ),
      body: StreamBuilder(
        stream: context.read<AuthenticationProvider>().userStream(userID: uid),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userModel =
              UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
            child: Column(
              children: [
                Center(
                  child: userImageWidget(
                    imageUrl: userModel.image,
                    radius: 60,
                    onTap: () {
                      // Navigate to user profile with uid as argument
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  userModel.name,
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Display phone number
                if (currentUser.uid == userModel.uid)
                  Text(
                    userModel.phoneNumber,
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 10),
                buildFriendRequestButton(
                  currentUser: currentUser,
                  userModel: userModel,
                ),
                const SizedBox(height: 10),
                buildFriendsButton(
                  currentUser: currentUser,
                  userModel: userModel,
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('About Me',
                        style: GoogleFonts.openSans(
                            fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 10),
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                Text(
                  userModel.aboutMe,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Friend request button
  Widget buildFriendRequestButton({
    required UserModel currentUser,
    required UserModel userModel,
  }) {
    if (currentUser.uid == userModel.uid &&
        userModel.friendRequestsUIDs.isNotEmpty) {
      return buildElevatedButton(
        onPressed: () {
          // Navigate to friend requests screen
          Navigator.pushNamed(context, Constants.friendRequestsScreen);
        },
        label: 'View Friend Requests',
        width: MediaQuery.of(context).size.width * 0.7,
        backgroundColor: Theme.of(context).cardColor,
        textColor: Theme.of(context).primaryColor,
      );
    } else {
      // Not in our profile
      return const SizedBox.shrink();
    }
  }

  // Friends button
  Widget buildFriendsButton({
    required UserModel currentUser,
    required UserModel userModel,
  }) {
    if (currentUser.uid == userModel.uid && userModel.friendsUIDs.isNotEmpty) {
      return buildElevatedButton(
        onPressed: () {
          // Navigate to friends screen
          Navigator.pushNamed(context, Constants.friendsScreen);
        },
        label: 'View Friends',
        width: MediaQuery.of(context).size.width * 0.7,
        backgroundColor: Theme.of(context).cardColor,
        textColor: Theme.of(context).primaryColor,
      );
    } else {
      if (currentUser.uid != userModel.uid) {
        //show cancel friend request button if the user has sent us a friend request
        //else show send friend request button
        if (userModel.friendRequestsUIDs.contains(currentUser.uid)) {
          // Show send friend request button
          return buildElevatedButton(
            onPressed: () async {
              await context
                  .read<AuthenticationProvider>()
                  .cancelFriendRequest(friendID: userModel.uid)
                  .whenComplete(() {
                showSnackBar(context, 'Friend request cancelled');
              });
            },
            label: 'Cancel Friend Request',
            width: MediaQuery.of(context).size.width * 0.7,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).primaryColor,
          );
        } else if (userModel.sentFriendRequestsUIDs.contains(currentUser.uid)) {
          return buildElevatedButton(
            onPressed: () async {
              await context
                  .read<AuthenticationProvider>()
                  .acceptFriendRequest(friendID: userModel.uid)
                  .whenComplete(() {
                showSnackBar(
                    context, 'You are now friends with ${userModel.name}');
              });
            },
            label: 'Accept Friend Request',
            width: MediaQuery.of(context).size.width * 0.7,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).primaryColor,
          );
        } else if (userModel.friendsUIDs.contains(currentUser.uid)) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildElevatedButton(
                onPressed: () async {
                  //show unfriend dialog to ask user if they are sure they want to unfriend
                  // Create a dialog to confirm logout
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title:
                          const Text('Unfriend', textAlign: TextAlign.center),
                      content: Text(
                          'Are you sure you want to unfriend ${userModel.name}?',
                          textAlign: TextAlign.center),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            // Unfriend
                            await context
                                .read<AuthenticationProvider>()
                                .unfriend(friendID: userModel.uid)
                                .whenComplete(() {
                              showSnackBar(
                                  context, 'You are no longer friends');
                            });
                          },
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );
                },
                label: 'Unfriend',
                width: MediaQuery.of(context).size.width * 0.4,
                backgroundColor:
                    Theme.of(context).buttonTheme.colorScheme!.primary,
                textColor: Colors.white,
              ),
              buildElevatedButton(
                onPressed: () async {
                  // Navigate to chat screen
                  // Navigate to chat screen with the following arguments
                  // 1. friendID 2. friendName 3. friendImage 4. groupID with an empty string
                  Navigator.pushNamed(context, Constants.chatScreen,
                      arguments: {
                        Constants.contactUID: userModel.uid,
                        Constants.contactName: userModel.name,
                        Constants.contactImage: userModel.image,
                        Constants.groupId: ''
                      });
                },
                label: 'Chat',
                width: MediaQuery.of(context).size.width * 0.4,
                backgroundColor: Theme.of(context).cardColor,
                textColor: Theme.of(context).primaryColor,
              ),
            ],
          );
        } else {
          return buildElevatedButton(
            onPressed: () async {
              await context
                  .read<AuthenticationProvider>()
                  .sendFriendRequest(friendID: userModel.uid)
                  .whenComplete(() {
                showSnackBar(context, 'Friend request sent');
              });
            },
            label: 'Send Friend Request',
            width: MediaQuery.of(context).size.width * 0.7,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).primaryColor,
          );
        }
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget buildElevatedButton({
    required String label,
    required VoidCallback onPressed,
    required double width,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.openSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
