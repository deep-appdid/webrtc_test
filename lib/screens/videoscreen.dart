import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoScreen extends StatefulWidget {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final Function(bool) onToggleAudio;
  final Function(bool) onToggleVideo;

  const VideoScreen({
    Key? key,
    required this.localRenderer,
    required this.remoteRenderer,
    required this.onToggleAudio,
    required this.onToggleVideo,
  }) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  bool isAudioOn = true, isVideoOn = true, isFrontCameraSelected = true;

  _toggleMic() {
    setState(() {
      isAudioOn = !isAudioOn;
      widget.onToggleAudio(isAudioOn);
    });
  }

  _toggleCamera() {
    setState(() {
      isVideoOn = !isVideoOn;
      widget.onToggleVideo(isVideoOn);
    });
  }

  _switchCamera() {
    isFrontCameraSelected = !isFrontCameraSelected;

    // If the local stream exists, switch the camera
    widget.localRenderer.srcObject?.getVideoTracks().forEach((track) {
      if (track.kind == 'video') {
        // New way to switch the camera (as of Flutter WebRTC 0.7.0)
        track.switchCamera();
      }
    });
    setState(() {});
  }

  _leaveCall() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    super.dispose();
    widget.localRenderer.srcObject
        ?.getTracks()
        .forEach((track) => track.stop());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Expanded(
        child: Stack(
          children: [
            RTCVideoView(
              widget.remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: SizedBox(
                height: 150,
                width: 120,
                child: RTCVideoView(
                  widget.localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(isAudioOn ? Icons.mic : Icons.mic_off),
              onPressed: _toggleMic,
            ),
            IconButton(
              icon: const Icon(Icons.call_end),
              iconSize: 30,
              onPressed: _leaveCall,
            ),
            IconButton(
              icon: const Icon(Icons.cameraswitch),
              onPressed: _switchCamera,
            ),
            IconButton(
              icon: Icon(isVideoOn ? Icons.videocam : Icons.videocam_off),
              onPressed: _toggleCamera,
            ),
          ],
        ),
      ),
    ]));
  }
}
