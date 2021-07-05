import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'api_exception.dart';
import 'models/signup.dart';
import 'package:univintel_gbn_app/globals.dart' as Globals;
import 'package:random_string/random_string.dart';

class ApiService {

  final _storage = new FlutterSecureStorage();

  Future<dynamic> postJson(String url, dynamic model) async {
    final token = await _storage.read(key: 'api_token');
    final response = await http.post(Globals.apiHost + url,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'GBNToken=' + token
        },
        body: jsonEncode(model)
    );

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      return json.decode(response.body);
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed');
    }
  }

  Future<dynamic> post(String url, dynamic model) async {
    final token = await _storage.read(key: 'api_token');
    final response = await http.post(Globals.apiHost + url,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'GBNToken=' + token
        },
        body: jsonEncode(model)
    );

    if (response.statusCode == 200 && response.body.length > 0)
      return json.decode(response.body);
    else 
      throw ApiException(response.statusCode, response.body.toString());
  }

  Future<dynamic> get(String url) async {
    String token = await _storage.read(key: 'api_token');
    final response =
        await http.get(Globals.apiHost + url, headers: {'Cookie': 'GBNToken=' + token});

    if (response.statusCode == 200 && response.body.length > 0)
      return json.decode(response.body);
    else throw ApiException(response.statusCode, response.body.toString());
  }

  Future getWithoutResult(String url) async {
    String token = await _storage.read(key: 'api_token');
    final response =
        await http.get(Globals.apiHost + url, headers: {'Cookie': 'GBNToken=' + token});

    if (response.statusCode == 200) return;
    else throw ApiException(response.statusCode, response.body.toString());
  }

  Future<dynamic> getWithoutSession(String url) async {
    final response = await http.get(Globals.apiHost + url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed');
    }
  }

  Future<String> signup(Signup model) async {
    final response = await http.get(Globals.apiHost +
        'api/1/authentification/signup?email=' +
        model.email +
        '&timeZone=' +
        model.timeZone);

    if (response.statusCode == 200 || response.statusCode == 204) {
      // If the call to the server was successful, parse the JSON.
      return response.body;
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed');
    }
  }

  Future<dynamic> verufyEmail(String email, String code) async {
    final response = await http.get(Globals.apiHost + 'api/1/authentification/verify?email=$email&code=$code');

    if (response.statusCode == 200 || response.statusCode == 204) {
      // If the call to the server was successful, parse the JSON.
      return response.body.length > 0 ? json.decode(response.body) : {};
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed');
    }
  }

  Future<String> signin(String email, String password) async {
    final response = await http.get(Globals.apiHost +
        'api/1/authentification/signin?email=' +
        email +
        '&code=' +
        password);

    if (response.statusCode == 200 && response.body.length > 0) {
      await _storage.write(key: 'api_token', value: response.body);
      Globals.currentUserToken = response.body;
      return "";
    }
    return response.body;
  }

  Future<String> trysignin(String email, String languageCode) async {
    final response = await http.get(Globals.apiHost +
        'api/1/authentification/trysignin?email=' +
        email);

    return response.body;
  }

  Future<String> checkEmail(String email) async {
    String token = await _storage.read(key: 'api_token');
    final response =
        await http.get(Globals.apiHost + "api/1/account/checkemail?email=$email", headers: {'Cookie': 'GBNToken=' + token});

    return response.body;
  }

  NetworkImage getNetworkImage(String id) {
    final token = Globals.currentUserToken;
    return NetworkImage(Globals.apiHost + 'api/1/images/avatar?id=' + id, headers: {'Cookie': 'GBNToken=' + token});
  }

  NetworkImage getNetworkImageFromFiles(String id, {bool fixCache = false}) {
    final token = Globals.currentUserToken;
    return NetworkImage(Globals.apiHost + 'api/1/files/download?id=' + id + (fixCache ? "&v=" + randomString(12) : ""), headers: {'Cookie': 'GBNToken=' + token});
  }

  Future<String> uploadImage(File imageFile, {String type = "",  String id = ""} ) async {
      final stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
      final length = await imageFile.length();

      final uri = Uri.parse(Globals.apiHost + 'api/1/images/add');
      final token = await _storage.read(key: 'api_token');
      var request = new http.MultipartRequest("POST", uri);
      request.headers['Cookie'] = 'GBNToken=' + token;

      final multipartFile = new http.MultipartFile(
        'file', 
        stream, 
        length,
        filename: basename(imageFile.path)
      );

      if (type.isNotEmpty) request.fields["type"] = type;
      if (id.isNotEmpty) request.fields["id"] = id;
      
      request.files.add(multipartFile);

      final response = await request.send();
      final result = await response.stream.bytesToString(); 
      
      return result != null && result.length > 0 ? result : "";
  }

  Future<String> uploadFile(File imageFile, { String companyId = "", String tag = "", String id = "" }) async {
      final stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
      final length = await imageFile.length();

      final uri = Uri.parse(Globals.apiHost + 'api/1/files/upload');
      final token = await _storage.read(key: 'api_token');
      var request = new http.MultipartRequest("POST", uri);
      request.headers['Cookie'] = 'GBNToken=' + token;

      final multipartFile = new http.MultipartFile(
        'file', 
        stream, 
        length,
        filename: basename(imageFile.path)
      );
      if (companyId.isNotEmpty) {
        request.fields["companyId"] = companyId;
      }
      if (tag.isNotEmpty) request.fields["tag"] = tag;
      if (id.isNotEmpty) request.fields["id"] = id;
      request.files.add(multipartFile);

      final response = await request.send();
      final result = await response.stream.bytesToString(); 
      
      return result != null && result.length > 0 ? result : "";
  }
}
