// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';

// class AudioPlayerWidget extends StatefulWidget {
//   const AudioPlayerWidget({super.key, required this.audioUrl});
//   final String audioUrl;

//   @override
//   State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
// }

// class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
//   AudioPlayer audioPlayer = AudioPlayer();
//   Duration duration = const Duration();
//   Duration position = const Duration();
//   bool isPlaying = false;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         CircleAvatar(
//           radius: 22,
//           backgroundColor: Colors.orangeAccent,
//           child: CircleAvatar(
//             radius: 20,
//             child: IconButton(
//               icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
//               onPressed: () async {
//                 if (!isPlaying) {
//                   await audioPlayer.play(UrlSource(widget.audioUrl));
//                   setState(() {
//                     isPlaying = true;
//                   });
//                 } else {
//                   await audioPlayer.pause();
//                   setState(() {
//                     isPlaying = false;
//                   });
//                 }
//               },
//             ),
//           ),
//         ),
//         Expanded(
//           child: Slider.adaptive(
//             value: position.inSeconds.toDouble(),
//             max: duration.inSeconds.toDouble(),
//             onChanged: (value) {
//               setState(() {
//                 audioPlayer.seek(Duration(seconds: value.toInt()));
//               });
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
