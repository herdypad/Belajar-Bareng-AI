import 'package:dio/dio.dart';

import '../models/question.dart';
import 'ai_provider.dart';
import 'ai_response_parser.dart';

class AnthropicProvider implements AiProvider {
  final Dio _dio;
  final String apiKey;
  final String model;
  final String baseUrl;

  AnthropicProvider({
    required this.apiKey,
    required this.model,
    required this.baseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  @override
  Future<List<Question>> generateQuestions({
    required String topic,
    required int count,
  }) async {
    if (apiKey.isEmpty) {
      throw AiException('API key Anthropic belum diatur. Buka Pengaturan.');
    }
    try {
      final res = await _dio.post(
        '$baseUrl/messages',
        options: Options(headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        }),
        data: {
          'model': model,
          'max_tokens': 4096,
          'messages': [
            {'role': 'user', 'content': buildPrompt(topic: topic, count: count)},
          ],
        },
      );
      final content = res.data['content'][0]['text'] as String? ?? '';
      return parseQuestions(content);
    } on DioException catch (e) {
      throw AiException('Gagal memanggil Anthropic: ${e.message}');
    } catch (e) {
      throw AiException('Terjadi kesalahan: $e');
    }
  }

  @override
  Future<bool> testConnection() async {
    if (apiKey.isEmpty) {
      throw AiException('API key Anthropic belum diatur.');
    }
    try {
      final res = await _dio.post(
        '$baseUrl/messages',
        options: Options(headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        }),
        data: {
          'model': model,
          'max_tokens': 10,
          'messages': [
            {'role': 'user', 'content': 'Hello'},
          ],
        },
      );
      return res.statusCode == 200;
    } on DioException catch (e) {
      throw AiException('Koneksi gagal: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      throw AiException('Terjadi kesalahan: $e');
    }
  }
}
