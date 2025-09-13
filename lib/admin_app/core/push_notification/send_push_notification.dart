import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:prototype/admin_app/core/service/auth2service.dart';

Future<void> sendPushNotificationToActiveUsers({
  required String projectId,
  String? action, // ✅ optional, for buy/sell
  required String stockName,
  Map<String, dynamic>? extraData,
  bool isTargetUpdate = false,
}) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('customers')
        .where('active', isEqualTo: true)
        .where('isLoggedIn', isEqualTo: true)
        .get();

    if (snapshot.docs.isEmpty) {
      print("⚠️ No active logged-in users found.");
      return;
    }

    final accessToken = await getAccessToken();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final token = data['fcmToken'];
      if (token == null || token.isEmpty) continue;

      // --- Title depends on type ---
      final title = isTargetUpdate
          ? "📈 $stockName"
          : "📈 Stock Alert - $stockName";

      // --- Body text ---
      String bodyText = "";

      if (isTargetUpdate) {
        bodyText = "Action: Target Updated";
        if (extraData != null && extraData.isNotEmpty) {
          for (var entry in extraData.entries) {
            bodyText += "\n${entry.key.toUpperCase()}: ${entry.value}";
          }
        }
      } else {
        if (action != null && action.isNotEmpty) {
          bodyText = "Action: ${action[0].toUpperCase()}${action.substring(1)}";
        } else {
          bodyText = "Action: Unknown";
        }
      }

      // --- Message payload ---
      final message = {
        "message": {
          "token": token,
          "notification": {"title": title, "body": bodyText},
          "android": {
            "priority": "high",
            "notification": {"channel_id": "default_channel"},
          },
          "apns": {
            "payload": {
              "aps": {
                "alert": {"title": title, "body": bodyText},
                "content-available": 1,
              },
            },
          },
          "data": {
            "stockName": stockName,
            if (action != null) "action": action,
            ...?extraData,
          },
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
        final error = jsonDecode(response.body);

        if (error["error"]?["details"] != null) {
          for (var detail in error["error"]["details"]) {
            if (detail["errorCode"] == "UNREGISTERED") {
              // 🔹 Clean up invalid token
              await FirebaseFirestore.instance
                  .collection('customers')
                  .doc(doc.id)
                  .update({'fcmToken': FieldValue.delete()});
              print("🗑️ Removed invalid token for ${doc.id}");
            }
          }
        }
      }
    }

    print("✅ Notifications sent to active & logged-in users");
  } catch (e) {
    print("❌ Error: $e");
  }
}
