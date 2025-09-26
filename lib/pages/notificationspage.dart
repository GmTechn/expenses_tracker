import 'package:expenses_tracker/components/mybutton.dart';
import 'package:expenses_tracker/pages/dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_provider.dart';
import 'package:expenses_tracker/models/notifications.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.allNotifications;

    return Scaffold(
      backgroundColor: const Color(0xff181a1e),
      appBar: AppBar(
        backgroundColor: const Color(0xff181a1e),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        // Ici on peut juste changer la couleur du leading par défaut
        iconTheme: const IconThemeData(
          color: Colors.white, // ← couleur de l'icône "back"
        ),
        // Si tu veux explicitement un bouton retour personnalisé, tu peux le faire comme ça
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Dismissible(
                    key: ValueKey(n.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      notifProvider.deleteNotification(
                          n.id); // à créer dans ton provider
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification deleted!')),
                      );
                    },
                    child: ListTile(
                      tileColor:
                          n.read ? const Color(0xff383a44) : Colors.green,
                      title: Text(n.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(n.description,
                          style: const TextStyle(color: Colors.white70)),
                      trailing: Text(
                        "${n.date.hour}:${n.date.minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                      onTap: () => notifProvider.markAsRead(n.id),
                    ),
                  ),
                );
              },
            ),
          ),
          MyButton(
            textbutton: 'Mark all as read',
            onTap: notifProvider.markAllAsRead,
            buttonHeight: 40,
            buttonWidth: 200,
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
