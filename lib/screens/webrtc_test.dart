import 'package:demo_agora/screens/signaling.dart';
import 'package:demo_agora/screens/videoscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRtcTest extends StatefulWidget {
  const WebRtcTest({Key? key}) : super(key: key);

  @override
  State<WebRtcTest> createState() => _WebRtcTestState();
}

class _WebRtcTestState extends State<WebRtcTest> {
  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void _navigateToRTCVideoScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoScreen(
          localRenderer: _localRenderer,
          remoteRenderer: _remoteRenderer,
          onToggleAudio: _toggleAudioTrack,
          // Pass the callback functions here
          onToggleVideo: _toggleVideoTrack,
        ),
      ),
    );
  }

  void _toggleAudioTrack(bool isEnabled) {
    _localRenderer.srcObject?.getAudioTracks().forEach((track) {
      track.enabled = isEnabled;
    });
  }

  void _toggleVideoTrack(bool isEnabled) {
    _localRenderer.srcObject?.getVideoTracks().forEach((track) {
      track.enabled = isEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to Flutter Explained - WebRTC"),
      ),
      body: SafeArea(
        child: Column(children: [
          ElevatedButton(
            onPressed: () {
              signaling.openUserMedia(_localRenderer, _remoteRenderer);
            },
            child: const Text("Open camera & microphone"),
          ),
          ElevatedButton(
            onPressed: () async {
              roomId = await signaling.createRoom(_remoteRenderer);
              textEditingController.text = roomId!;
              setState(() {});
              print("roomId : $roomId");
              _navigateToRTCVideoScreen(); // Navigate to RTCVideoScreen after creating room
            },
            child: const Text("Create room"),
          ),
          ElevatedButton(
            onPressed: () {
              signaling.joinRoom(
                textEditingController.text.trim(),
                _remoteRenderer,
              );
              _navigateToRTCVideoScreen(); // Navigate to RTCVideoScreen after joining room
            },
            child: const Text("Join room"),
          ),
          ElevatedButton(
            onPressed: () {
              signaling.hangUp(_localRenderer);
              setState(() {});
            },
            child: const Text("Hangup"),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Join Room: "),
                Flexible(
                  child: TextFormField(
                    controller: textEditingController,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8)
        ]),
      ),
    );
  }
}
