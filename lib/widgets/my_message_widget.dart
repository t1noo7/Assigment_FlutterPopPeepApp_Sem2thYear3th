import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/models/message_model.dart';
import 'package:swipe_to/swipe_to.dart';

class MyMessageWidget extends StatelessWidget {
  const MyMessageWidget(
      {super.key, required this.message, required this.onRightSwipe});
  final MessageModel message;
  final Function() onRightSwipe;

  @override
  Widget build(BuildContext context) {
    final time = formatDate(message.timeSent, [hh, ':', nn, ' ']);
    final isReplying = message.repliedTo.isNotEmpty;

    return SwipeTo(
      onRightSwipe: (details) {
        onRightSwipe();
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            minWidth: MediaQuery.of(context).size.width * 0.3,
          ),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 30.0, top: 5.0, bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isReplying) ...[
                      Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColorDark
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                message.repliedTo,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                message.repliedMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    Text(
                      message.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Positioned(
                  bottom: 4,
                  right: 10,
                  child: Row(
                    children: [
                      Text(
                        time,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        message.isSeen ? Icons.done_all : Icons.done,
                        color: message.isSeen ? Colors.blue : Colors.white60,
                        size: 15,
                      ),
                    ],
                  ))
            ]),
          ),
        ),
      ),
    );
  }
}
