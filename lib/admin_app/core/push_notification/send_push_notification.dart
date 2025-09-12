import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prototype/admin_app/core/service/auth2service.dart';

Future<void> sendPushNotification({
  required String projectId,
  required String topic,
  required String action,
  required String stockName,
  Map<String, dynamic>? extraData, // ✅ added optional parameter
}) async {
  final accessToken = await getAccessToken();

  final url = Uri.parse(
    "https://fcm.googleapis.com/v1/projects/$projectId/messages:send",
  );

  // Build notification body text
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
      "topic": topic, // e.g. "allCustomers"
      "notification": {"title": "📈 Stock Alert: $stockName", "body": bodyText},
      "android": {
        "priority": "high",
        "notification": {
          "channel_id": "default_channel", // must match customer app
        },
      },
      "apns": {
        "payload": {
          "aps": {
            "alert": {"title": "📈 Stock Alert: $stockName", "body": bodyText},
            "sound": "default",
          },
        },
      },
      "data": {
        "action": action,
        "stockName": stockName,
        ...?extraData, // ✅ merge extra fields into data
      },
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
