import 'package:expenses_tracker/components/mybutton.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:expenses_tracker/services/notification_provider.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.allNotifications;

    return Scaffold(
      backgroundColor: Color(0xff181a1e),
      appBar: AppBar(
        backgroundColor: Color(0xff181a1e),
        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),

        //changing the return icon's color to white
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            //building a listview of notifications
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              itemCount: notifications.length,
              itemBuilder: (BuildContext context, int index) {
                final n = notifications[index];

                //creating a padding to have some spaces
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Dismissible(
                    key: ValueKey(n.id),
                    background: Container(
                      //generating a red dismissible with a white trash can
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(
                        CupertinoIcons.trash_fill,
                        color: Colors.white,
                      ),
                    ),

                    ///direction the dismissible should take
                    ///and when dismissed , a notification is deleted
                    ///by the help of the provider
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      notifProvider.deleteNotification(n.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Notification deleted!'),
                        ),
                      );
                    },

                    ///creating a listile to display a notification
                    ///with title and etc...and when tapped , it's read automatically
                    ///
                    child: ListTile(
                      tileColor: n.read ? Color(0xff383a44) : Colors.green,
                      title: Text(
                        n.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        n.description,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      trailing: Text(
                        '${n.date.hour}:${n.date.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
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
          SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
