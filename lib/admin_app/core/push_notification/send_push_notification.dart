import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:prototype/admin_app/core/service/auth2service.dart';

Future<void> sendPushNotificationToActiveUsers({
  required String projectId,
  required String action,
  required String stockName,
  Map<String, dynamic>? extraData,
}) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('customers')
      .where('active', isEqualTo: true)
      .where('isLoggedIn', isEqualTo: true)
      .get();

  if (snapshot.docs.isEmpty) return;

  final accessToken = await getAccessToken();

  for (var doc in snapshot.docs) {
    final data = doc.data();
    final token = data['fcmToken'];
    if (token == null) continue;

    String bodyText = "Action: $action";
    if (extraData != null && extraData.isNotEmpty) {
      bodyText +=
          "\n" +
          extraData.entries
              .map((e) => "${e.key.toUpperCase()}: ${e.value}")
              .join("\n");
    }

    final message = {
      "message": {
        "token": token, // per-user
        "notification": {
          "title": "📈 Stock Alert: $stockName",
          "body": bodyText,
        },
        "android": {
          "priority": "high",
          "notification": {"channel_id": "default_channel"},
        },
        "apns": {
          "payload": {
            "aps": {
              "alert": {
                "title": "📈 Stock Alert: $stockName",
                "body": bodyText,
              },
              "sound": "default",
              "content-available": 1,
            },
          },
        },
        "data": {"action": action, "stockName": stockName, ...?extraData},
      },
    };

    final response = await http.post(
      Uri.parse(
        "https://fcm.googleapis.com/v1/projects/$projectId/messages:send",
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode(message),
    );

    if (response.statusCode != 200) {
      print("❌ Error sending to ${doc.id}: ${response.body}");
    }
  }

  print("✅ Notifications sent to active & logged-in users");
}
