import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

Future<String> getAccessToken() async {
  // Load service account JSON from assets
  final serviceAccountJson = await rootBundle.loadString(
    "assets/serviceAccountKey.json",
  );
  final credentials = auth.ServiceAccountCredentials.fromJson(
    serviceAccountJson,
  );

  final scopes = ["https://www.googleapis.com/auth/firebase.messaging"];

  final client = await auth.clientViaServiceAccount(credentials, scopes);
  final accessToken = client.credentials.accessToken.data;

  client.close();
  return accessToken;
}
