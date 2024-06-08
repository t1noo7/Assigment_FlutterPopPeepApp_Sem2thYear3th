import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/providers/authentication_provider.dart';
import 'package:flutter_chat_app/utilities/global_methods.dart';
import 'package:provider/provider.dart';

// class GroupChatAppBar extends StatefulWidget {
//   const GroupChatAppBar({super.key, required this.groupId});
//   final String groupId;

//   @override
//   State<GroupChatAppBar> createState() => _GroupChatAppBarState();
// }

// class _GroupChatAppBarState extends State<GroupChatAppBar> {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: context
//           .read<AuthenticationProvider>()
//           .userStream(userID: widget.groupId),
//       builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//         if (snapshot.hasError) {
//           return const Center(child: Text('Something went wrong'));
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final groupModel =
//             GroupModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

//         return Row(
//           children: [
//             userImageWidget(
//               imageUrl: groupModel.groupImage,
//               radius: 20,
//               onTap: () {
//                 // Navigate to group setings screen
//               },
//             ),
//             const SizedBox(width: 10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(groupModel.groupName),
//                 const Text(
//                   'Group description or group members',
//                     style: TextStyle(fontSize: 12)),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }
// }