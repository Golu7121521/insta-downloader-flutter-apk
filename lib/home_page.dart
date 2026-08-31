import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

import 'main.dart';
import 'video_api_service.dart';
import 'video_preview_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();

  String? _resolvedVideoUrl;
  bool _isFetching = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _fetchVideo() async {
    final input = _urlController.text.trim();
    if (input.isEmpty) {
      setState(() => _errorMessage = 'Please enter a video link first.');
      return;
    }

    setState(() {
      _isFetching = true;
      _errorMessage = null;
    });

    try {
      final resolvedUrl = await VideoApiService.fetchVideoUrl(input);
      setState(() {
        _resolvedVideoUrl = resolvedUrl;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not fetch video: $e';
        _resolvedVideoUrl = null;
      });
    } finally {
      setState(() => _isFetching = false);
    }
  }

  Future<void> _saveToGallery() async {
    if (_resolvedVideoUrl == null) return;

    setState(() => _isSaving = true);

    try {
      final response = await http.get(Uri.parse(_resolvedVideoUrl!));
      if (response.statusCode != 200) {
        throw Exception('Download failed (status ${response.statusCode})');
      }

      final tempDir = await getTemporaryDirectory();
      final fileName =
          'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      await Gal.putVideo(filePath);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: kPinkAccent),
              SizedBox(width: 12),
              Text('Video saved to gallery successfully!'),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save video: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Preview')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Paste a video link',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _urlController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'https://example.com/video-link',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isFetching ? null : _fetchVideo,
                child: _isFetching
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Fetch Video'),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
              if (_resolvedVideoUrl != null) ...[
                const SizedBox(height: 28),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: VideoPreviewPlayer(
                      key: ValueKey(_resolvedVideoUrl),
                      videoUrl: _resolvedVideoUrl!,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveToGallery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPurpleAccent,
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download_rounded),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save to Gallery',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
