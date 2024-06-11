import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_app/constants.dart';
import 'package:flutter_chat_app/providers/authentication_provider.dart';
import 'package:flutter_chat_app/providers/chat_provider.dart';
import 'package:flutter_chat_app/utilities/global_methods.dart';
import 'package:flutter_chat_app/widgets/message_reply_preview.dart';
// import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField(
      {super.key,
      required this.contactUID,
      required this.contactName,
      required this.contactImage,
      required this.groupId});
  final String contactUID;
  final String contactName;
  final String contactImage;
  final String groupId;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  // FlutterSoundRecord? _soundRecord;
  File? finalFileImage;
  String filePath = '';

  // bool isRecording = false;
  // bool isShowSendButton = false;
  // bool isSendingAudio = false;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    // _soundRecord = FlutterSoundRecord();
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    // _soundRecord?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  //check microphone permission
  // Future<bool> checkMicrophonePermission() async {
  //   bool hasPermission = await Permission.microphone.isGranted;
  //   final status = await Permission.microphone.request();
  //   if (status == PermissionStatus.granted) {
  //     hasPermission = true;
  //   } else {
  //     hasPermission = false;
  //   }
  //   return hasPermission;
  // }

  //start recording audio
  // void startRecording() async {
  //   final hasPermission = await checkMicrophonePermission();
  //   if (hasPermission) {
  //     var tempDir = await getTemporaryDirectory();
  //     filePath = '${tempDir.path}/flutter_sound.aac';
  //     await _soundRecord!.start(path: filePath);
  //     setState(() {
  //       isRecording = true;
  //     });
  //   }
  // }

  //stop recording audio
  // void stopRecording() async {
  //   await _soundRecord!.stop();
  //   setState(() {
  //     isRecording = false;
  //     isSendingAudio = true;
  //   });
  //   //send audio message to firestore
  //   sendFileMessage(messageType: MessageEnum.audio);
  // }

  void selectImage(bool fromCamera) async {
    final finalFileImage = await pickImage(
      fromCamera: fromCamera,
      onFall: (String message) {
        showSnackBar(context, message);
      },
    );
    //crop image
    await cropImage(finalFileImage?.path);
    popContext();
  }

  popContext() {
    Navigator.pop(context);
  }

  Future<void> cropImage(croppedFilePath) async {
    if (croppedFilePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: croppedFilePath,
          maxHeight: 800,
          maxWidth: 800,
          compressQuality: 90);

      if (croppedFile != null) {
        filePath = croppedFile.path;
        //send image message to firestore
        sendFileMessage(messageType: MessageEnum.image);
      }
    }
  }

  //send image message to firestore
  void sendFileMessage({required MessageEnum messageType}) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    final chatProvider = context.read<ChatProvider>();

    chatProvider.sendFileMessage(
      sender: currentUser,
      contactUID: widget.contactUID,
      contactName: widget.contactName,
      contactImage: widget.contactImage,
      file: File(filePath),
      messageType: messageType,
      groupId: widget.groupId,
      onSuccess: () {
        _textEditingController.clear();
        _focusNode.requestFocus();
        // _focusNode.unfocus();
        // setState(() {
        //   // isSendingAudio = false;
        // });
      },
      onError: (error) {
        showSnackBar(context, error);
      },
    );
  }

  //send text message to firestore
  void sendTextMessage() {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    final chatProvider = context.read<ChatProvider>();

    chatProvider.sendTextMessage(
      sender: currentUser,
      contactUID: widget.contactUID,
      contactName: widget.contactName,
      contactImage: widget.contactImage,
      message: _textEditingController.text,
      messageType: MessageEnum.text,
      groupId: widget.groupId,
      onSuccess: () {
        _textEditingController.clear();
        _focusNode.unfocus();
      },
      onError: (error) {
        showSnackBar(context, error);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final messageReply = chatProvider.messageReplyModel;
        final isMessageReply = messageReply != null;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Theme.of(context).cardColor,
            border: Border.all(color: Theme.of(context).colorScheme.primary),
          ),
          child: Column(
            children: [
              isMessageReply
                  ? const MessageReplyPreview()
                  : const SizedBox.shrink(),
              Row(
                children: [
                  chatProvider.isLoading
                      ? const CircularProgressIndicator()
                      : IconButton(
                          icon: const Icon(Icons.attachment),
                          // onPressed: isSendingAudio
                          //     ? null

                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return SizedBox(
                                  height: 200,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        //select image from camera
                                        ListTile(
                                          leading: const Icon(Icons.camera_alt),
                                          title: const Text('Camera'),
                                          onTap: () {
                                            selectImage(true);
                                          },
                                        ),
                                        //select image from gallery
                                        ListTile(
                                          leading: const Icon(Icons.image),
                                          title: const Text('Gallery'),
                                          onTap: () {
                                            selectImage(false);
                                          },
                                        ),
                                        //select a video file from device
                                        ListTile(
                                          leading:
                                              const Icon(Icons.video_library),
                                          title: const Text('Video'),
                                          onTap: () {
                                            //select video file
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                  Expanded(
                    child: TextFormField(
                      controller: _textEditingController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration.collapsed(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Type a message'),
                      // onChanged: (value) {
                      //   setState(() {
                      //     // isShowSendButton = value.isNotEmpty;
                      //   });
                      // },
                    ),
                  ),
                  chatProvider.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )
                      : GestureDetector(
                          onTap: () {
                            sendTextMessage();
                          },
                          // onTap: isShowSendButton ? sendTextMessage : null,
                          // onLongPress: isShowSendButton ? null : startRecording,
                          // onLongPressUp: stopRecording,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.deepPurple,
                            ),
                            margin: const EdgeInsets.all(5),
                            child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.arrow_upward,
                                    color: Colors.white)
                                // isShowSendButton
                                //     ? const Icon(Icons.arrow_upward,
                                //         color: Colors.white)
                                //     : const Icon(Icons.mic, color: Colors.white),
                                ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
