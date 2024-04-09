import 'dart:convert';

import 'package:app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http_parser/http_parser.dart';

Future<String> _getBearer() async {
  if (supabase.auth.currentSession?.isExpired ?? false) {
    try {
      await supabase.auth.refreshSession();
    } catch (_) {}
  }

  final authBearer =
      supabase.auth.currentSession?.accessToken ?? supabaseAnonKey;

  return authBearer;
}

Future<FunctionResponse> _invoke(
    {required String functionName,
    Map<String, String>? fields = const {},
    List<http.MultipartFile>? files}) async {
  final uri = Uri.parse("$supabaseFunctionsURL/$functionName");
  final bearer = await _getBearer();

  var request = http.MultipartRequest('POST', uri);
  request.headers['Authorization'] = 'Bearer $bearer';

  if (fields != null) request.fields.addAll(fields);
  if (files != null) request.files.addAll(files);

  var response = await http.Response.fromStream(await request.send());
  var data = jsonDecode(utf8.decode(response.bodyBytes));

  if (200 <= response.statusCode && response.statusCode < 300) {
    return FunctionResponse(data: data, status: response.statusCode);
  } else {
    throw FunctionException(
      status: response.statusCode,
      details: data,
      reasonPhrase: response.reasonPhrase,
    );
  }
}

Future<FunctionResponse> addSound(
    {required String name,
    required Uint8List thumbnail,
    required Uint8List audio}) {
  return _invoke(functionName: "add-sound", fields: {
    'name': name
  }, files: [
    http.MultipartFile.fromBytes("thumbnail", thumbnail,
        contentType: MediaType.parse("image/*"), filename: 'thumbnail'),
    http.MultipartFile.fromBytes("audio", audio,
        contentType: MediaType.parse("audio/*"), filename: 'audio')
  ]);
}

Future<FunctionResponse> editSound(
    {required String id, String? name, Uint8List? thumbnail}) {
  if (name == null && thumbnail == null) {
    throw Exception('Both name and thumbnail cannot be simultaneously null.');
  }
  return _invoke(
      functionName: "edit-sound",
      fields: name == null ? {'id': id} : {'id': id, 'name': name},
      files: thumbnail == null
          ? []
          : [
              http.MultipartFile.fromBytes("thumbnail", thumbnail,
                  contentType: MediaType.parse("image/*"),
                  filename: 'thumbnail'),
            ]);
}
