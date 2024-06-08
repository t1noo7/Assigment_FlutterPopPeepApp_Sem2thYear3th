//show snackBar
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utilities/assets_manager.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
  ));
}

Widget userImageWidget({
  required String imageUrl,
  required double radius,
  required Function() onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      backgroundImage: imageUrl.isEmpty
          ? NetworkImage(imageUrl)
          : const AssetImage(AssetsManager.userImage) as ImageProvider,
    ),
  );
}

//pick image from library or camera
Future<File?> pickImage(
    {required bool fromCamera, required Function(String) onFall}) async {
  File? fileImage;
  if (fromCamera) {
    //get picture from camera
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile == null) {
        onFall('No image selected');
      } else {
        fileImage = File(pickedFile.path);
      }
    } catch (e) {
      onFall(e.toString());
    }
  } else {
    //get picture from gallery
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        onFall('No image selected');
      } else {
        fileImage = File(pickedFile.path);
      }
    } catch (e) {
      onFall(e.toString());
    }
  }
  return fileImage;
}
