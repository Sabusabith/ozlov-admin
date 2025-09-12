import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prototype/core/service/auth2service.dart';

Future<void> sendPushNotification({
  required String projectId,
  required String topic,
  required String action,
  required String stockName,
}) async {
  final accessToken = await getAccessToken();

  final url = Uri.parse(
    "https://fcm.googleapis.com/v1/projects/$projectId/messages:send",
  );

  final message = {
    "message": {
      "topic": topic, // e.g. "allCustomers"
      "notification": {
        "title": "📈 Stock Alert: $stockName",
        "body": "Action: $action",
      },
      "android": {
        "priority": "high", // 👈 priority belongs here
        "notification": {
          "channel_id": "default_channel", // must match your customer app
        },
      },
      "apns": {
        "payload": {
          "aps": {
            "alert": {
              "title": "📈 Stock Alert: $stockName",
              "body": "Action: $action",
            },
            "sound": "default",
          },
        },
      },
      "data": {"action": action, "stockName": stockName},
    },
  };

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },
    body: jsonEncode(message),
  );

  if (response.statusCode == 200) {
    print("✅ Notification sent: ${response.body}");
  } else {
    print("❌ Error: ${response.statusCode} ${response.body}");
  }
}
