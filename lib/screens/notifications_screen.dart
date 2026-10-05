import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Notifications'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0),
      body: FutureBuilder<List<Map<String, String>>>(
        future: ApiService().getNotifications(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.data!.isEmpty) {
            return const Center(child: Text('No notifications'));
          }
          return ListView.separated(
            itemCount: snap.data!.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final n = snap.data![i];
              return ListTile(
                leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF5EFEC),
                    child: Icon(Icons.notifications_none, color: Colors.black)),
                title: Text(n['title']!, style: const TextStyle(fontSize: 13)),
                trailing: Text(n['time']!,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
              );
            },
          );
        },
      ),
    );
  }
}
