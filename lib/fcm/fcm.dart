import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendPushNotification(String fcmToken, String action) async {
  final serverKey =
      "YOUR_SERVER_KEY_HERE"; // from Firebase Console → Project Settings → Cloud Messaging
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'key=$serverKey',
  };

  final body = jsonEncode({
    'to': fcmToken,
    'notification': {
      'title': 'Stock Update',
      'body': 'Action changed to $action',
      'sound': 'default',
    },
    'data': {'action': action},
  });

  await http.post(
    Uri.parse('https://fcm.googleapis.com/fcm/send'),
    headers: headers,
    body: body,
  );
}
