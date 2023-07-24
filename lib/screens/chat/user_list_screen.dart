import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_task_app/screens/auth/login_screen.dart';
import 'package:flutter_task_app/screens/chat/chat_screen.dart';
import '../../model/selected_user.dart';

class UserListScreen extends StatelessWidget {
  static const route = "userlist";

  void _handleSignOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // You can navigate to the login screen or any other screen after sign out
      // For example:
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.route, (route) => false);
    } catch (e) {
      print('Error signing out: $e');
      // Handle sign out error if necessary
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
            onTap: () {
              // FlutterLocalNotificationsPlugin.show();
            },
            child: const Text('Users List')),
        actions: [
          IconButton(
            onPressed: () => _handleSignOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUser = FirebaseAuth.instance.currentUser;
          final users = snapshot.data!.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return SelectedUser(
                    id: doc.id, name: data['name'], fcmToken: data['fcmToken']);
              })
              .where((user) =>
                  user.id != currentUser?.uid) // Filter out the current user
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person_2_rounded),
                ),
                title: Text(user.name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        currentUser: currentUser!,
                        otherUser: user,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
