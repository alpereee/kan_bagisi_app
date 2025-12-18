import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationHistoryScreen extends StatelessWidget {
  const NotificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("🔔 Bildirim Geçmişi")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("notifications")
            .where("userId", isEqualTo: uid)
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("📭 Henüz bildirim geçmişin yok."));
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? "Bildirim";
              final body = data['body'] ?? "";
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
              final status = data['status'] ?? "unknown";
              final error = data['error'] ?? "";

              // 🔹 İkon ve renk seçimi
              Icon statusIcon;
              if (status == "sent") {
                statusIcon =
                    const Icon(Icons.check_circle, color: Colors.green);
              } else if (status == "failed") {
                statusIcon = const Icon(Icons.error, color: Colors.red);
              } else {
                statusIcon = const Icon(Icons.info, color: Colors.grey);
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: statusIcon,
                  title: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(body),
                      if (error.isNotEmpty)
                        Text("⚠️ $error",
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12)),
                    ],
                  ),
                  trailing: createdAt != null
                      ? Text(
                          "${createdAt.day}/${createdAt.month} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
