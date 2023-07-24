import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../../model/selected_user.dart';

class ChatScreen extends StatelessWidget {
  final User currentUser;
  final SelectedUser otherUser;

  ChatScreen({required this.currentUser, required this.otherUser});

  final TextEditingController _messageController = TextEditingController();

  // void _sendMessage() async {
  //   String message = _messageController.text.trim();
  //   if (message.isNotEmpty) {
  //     String chatId = _getChatId(currentUser.uid, otherUser.id);
  //     FirebaseFirestore.instance.collection('chats/$chatId/messages').add({
  //       'text': message,
  //       'senderId': currentUser.uid,
  //       'timestamp': DateTime.now().toIso8601String(),
  //     });

  //     // Send push notification to the recipient user
  //     String recipientFCMToken = otherUser
  //         .fcmToken; // Get the FCM token from the recipient user profile
  //     if (recipientFCMToken != null) {
  //       String serverKey =
  //           'AAAAW-yG9PY:APA91bF8ChoMKbeDPhLDzOyPKpWHro1sVO2VKAkb3Y6qTw1rDgGhdhvT2sG0thhB9yFcgw5cslXTE6NnGd530RCZqWpmlUacfiSSZGdkzmTuwxzUisd1i_63w0q_Knj_5r7P-kSwLa5K'; // Replace with your FCM server key
  //       String url = 'https://fcm.googleapis.com/fcm/send';

  //       Map<String, dynamic> notification = {
  //         'title': 'New Message',
  //         'body': message,
  //         'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //       };

  //       Map<String, dynamic> messageData = {
  //         'to': recipientFCMToken,
  //         'notification': notification,
  //         'data': {
  //           'chatId': chatId,
  //         },
  //       };

  //       String jsonBody = jsonEncode(messageData);

  //       await http.post(
  //         Uri.parse(url),
  //         headers: <String, String>{
  //           'Content-Type': 'application/json',
  //           'Authorization': 'key=$serverKey',
  //         },
  //         body: jsonBody,
  //       );
  //     }

  //     _messageController.clear();
  //   }
  // }

  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      String chatId = _getChatId(currentUser.uid, otherUser.id);
      FirebaseFirestore.instance.collection('chats/$chatId/messages').add({
        'text': message,
        'senderId': currentUser.uid,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Send push notification to the recipient user
      String recipientFCMToken = otherUser
          .fcmToken; // Get the FCM token from the recipient user profile
      if (recipientFCMToken != null) {
        String serverKey =
            'AAAAW-yG9PY:APA91bF8ChoMKbeDPhLDzOyPKpWHro1sVO2VKAkb3Y6qTw1rDgGhdhvT2sG0thhB9yFcgw5cslXTE6NnGd530RCZqWpmlUacfiSSZGdkzmTuwxzUisd1i_63w0q_Knj_5r7P-kSwLa5K'; // Replace with your FCM server key
        // Replace with your FCM server key
        String url = 'https://fcm.googleapis.com/fcm/send';

        Map<String, dynamic> notification = {
          'title': 'New Message',
          'body': message,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        };

        Map<String, dynamic> messageData = {
          'to': recipientFCMToken,
          'notification': notification,
          'data': {
            'chatId': chatId,
          },
        };

        String jsonBody = jsonEncode(messageData);

        await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$serverKey',
          },
          body: jsonBody,
        );
      }

      _messageController.clear();
    }
  }

  String _getChatId(String userId1, String userId2) {
    // Sort the user IDs before combining to ensure consistent chat ID
    List<String> sortedUserIds = [userId1, userId2]..sort();
    return sortedUserIds.join('_');
  }

  @override
  Widget build(BuildContext context) {
    String chatId = _getChatId(currentUser.uid, otherUser.id);
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${otherUser.name}')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats/$chatId/messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error fetching data'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> messageData =
                        messages[index].data() as Map<String, dynamic>;
                    String messageText = messageData['text'];
                    String senderId = messageData['senderId'];
                    bool isOwnMessage =
                        FirebaseAuth.instance.currentUser!.uid == senderId;

                    // Determine alignment for the message based on the sender
                    AlignmentGeometry alignment = isOwnMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft;

                    return Align(
                      alignment: alignment,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: EdgeInsets.symmetric(
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isOwnMessage ? Colors.blue : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          messageText,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration:
                          const InputDecoration(labelText: 'Message...'),
                    ),
                  ),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
