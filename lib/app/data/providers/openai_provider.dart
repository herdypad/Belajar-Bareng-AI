
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../models/question.dart';
import 'ai_provider.dart';
import 'ai_response_parser.dart';

class OpenAiProvider implements AiProvider {
  final Dio _dio;
  final String apiKey;
  final String model;
  final String baseUrl;

  OpenAiProvider({
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
      throw AiException('API key OpenAI belum diatur. Buka Pengaturan.');
    }
    try {
      final res = await _dio.post(
        '$baseUrl/chat/completions',
        options: Options(headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        }),
        data: {
          'model': model,
          'messages': [
            {'role': 'user', 'content': buildPrompt(topic: topic, count: count)},
          ],
          'response_format': {'type': 'json_object'},
        },
      );
      
      // Parse response (bisa berupa SSE format atau pure JSON)
      Map<String, dynamic> jsonData;
      
      if (res.data is String) {
        // Handle SSE format: extract JSON from "data: {...}" lines
        final rawString = res.data as String;
        if (kDebugMode) {
          print('Raw response (truncated): ${rawString.substring(0, rawString.length > 500 ? 500 : rawString.length)}...');
        }
        
        // Extract JSON from SSE format
        final lines = rawString.split('\n');
        String? jsonStr;
        for (final line in lines) {
          if (line.startsWith('{') || (line.contains('{') && !line.startsWith('data:'))) {
            // Find first complete JSON object
            final start = line.indexOf('{');
            if (start != -1) {
              // Find matching closing brace
              int braceCount = 0;
              int end = -1;
              for (int i = start; i < line.length; i++) {
                if (line[i] == '{') braceCount++;
                if (line[i] == '}') {
                  braceCount--;
                  if (braceCount == 0) {
                    end = i;
                    break;
                  }
                }
              }
              if (end != -1) {
                jsonStr = line.substring(start, end + 1);
                break;
              }
            }
          }
        }
        
        if (jsonStr == null) {
          throw AiException('Tidak dapat menemukan JSON dalam response SSE');
        }
        
        try {
          jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to parse: $jsonStr');
          }
          throw AiException('JSON parsing error: $e');
        }
      } else if (res.data is Map) {
        jsonData = res.data as Map<String, dynamic>;
      } else {
        throw AiException('Response type tidak didukung: ${res.data.runtimeType}');
      }
      
      // Ekstrak content dari JSON
      String content;
      try {
        if (jsonData['choices'] is List) {
          content = jsonData['choices'][0]['message']['content'] as String? ?? '';
        } else if (jsonData['content'] != null) {
          content = jsonData['content'] as String;
        } else if (jsonData['message'] != null) {
          content = jsonData['message']['content'] as String? ?? jsonData['message'] as String;
        } else {
          throw AiException('Format response tidak memiliki field content/message/choices');
        }
      } catch (e) {
        throw AiException('Error ekstraksi content: $e');
      }
      
      return parseQuestions(content);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('DioException: ${e.message}');
        print('Response data: ${e.response?.data}');
      }
      throw AiException('Gagal memanggil OpenAI: ${e.message}');
    } on AiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
      throw AiException('Terjadi kesalahan: $e');
    }
  }

  @override
  Future<bool> testConnection() async {
    if (apiKey.isEmpty) {
      throw AiException('API key OpenAI belum diatur.');
    }
    try {
      final res = await _dio.post(
        '$baseUrl/chat/completions',
        options: Options(headers: {
          'Authorization': 'Bearer $apiKey',
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
      final msg = kIsWeb
          ? 'CORS error: browser memblokir request. Jalankan dengan --web-browser-flag "--disable-web-security" atau test di Android/iOS.'
          : 'Koneksi gagal: ${e.response?.statusCode} - ${e.message}';
      throw AiException(msg);
    } catch (e) {
      throw AiException('Terjadi kesalahan: $e');
    }
  }
}
