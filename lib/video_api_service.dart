import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoApiService {
  static Future<String> fetchVideoUrl(String inputUrl) async {
    // 1. Aapke asali Render API ka URL
    final apiUrl = Uri.parse('https://insta-downloader-api-nvpg.onrender.com/download?url=$inputUrl');

    // 2. API ko call karna
    final response = await http.get(apiUrl);

    // 3. Error handling
    if (response.statusCode != 200) {
      throw Exception('Failed to reach API (status ${response.statusCode})');
    }

    // 4. JSON se direct mp4 link nikalna
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data.containsKey('download_url') && data['download_url'] != null) {
      return data['download_url'] as String;
    } else {
      throw Exception('Video URL not found in API response');
    }
  }
}
