import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'main.dart';

class VideoPreviewPlayer extends StatefulWidget {
  final String videoUrl;

  const VideoPreviewPlayer({super.key, required this.videoUrl});

  @override
  State<VideoPreviewPlayer> createState() => _VideoPreviewPlayerState();
}

class _VideoPreviewPlayerState extends State<VideoPreviewPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _initialized = true);
      });
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant VideoPreviewPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller.removeListener(_onControllerUpdate);
      _controller.dispose();
      _initialized = false;
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
            ..initialize().then((_) {
              if (!mounted) return;
              setState(() => _initialized = true);
            });
      _controller.addListener(_onControllerUpdate);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _showOverlay = true;
      } else {
        _controller.play();
        _showOverlay = true;
      }
    });

    // Briefly show the overlay then hide it while playing.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (_controller.value.isPlaying) {
        setState(() => _showOverlay = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: const Color(0xFF1E1E1E),
          child: !_initialized
              ? const Center(
                  child: CircularProgressIndicator(
                    color: kPinkAccent,
                  ),
                )
              : GestureDetector(
                  onTap: () => setState(() => _showOverlay = !_showOverlay),
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                      // Gradient scrim for icon legibility.
                      IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: _showOverlay ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.15),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.25),
                                ],
                                stops: const [0, 0.5, 1],
                              ),
                            ),
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: _showOverlay ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [kPinkAccent, kPurpleAccent],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
